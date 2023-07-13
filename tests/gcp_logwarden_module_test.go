package test

import (
	"context"
	"fmt"
	"io/ioutil"
	"log"
	"math/rand"
	"testing"
	"time"

	"cloud.google.com/go/pubsub"
	"github.com/gruntwork-io/terratest/modules/gcp"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestLogwardenModule(t *testing.T) {
	//Basic module tests

	//Regions we're currently likely to deploy or DR in
	approvedRegions := []string{
		"us-central1",
		"us-east1",
		"us-east4",
		"us-east5",
		"us-west1",
		"us-west2",
		"us-west3",
		"us-west4",
		"us-south1",
	}

	terraformDir := "../examples/logwarden"

	test_structure.RunTestStage(t, "setup", func() {

		gcpRegion := gcp.GetRandomRegion(t, "id", approvedRegions, nil)

		// randomize with a unique seed for each test run to avoid name collisions
		rand.Seed(time.Now().UnixNano())
		uniqueId := fmt.Sprintf("%d", rand.Intn(9999))

		// Saved state we might need to pass between test stages
		test_structure.SaveString(t, terraformDir, "projectId", "terraform-test-project-0000")
		test_structure.SaveString(t, terraformDir, "savedGcpRegion", gcpRegion)
		test_structure.SaveString(t, terraformDir, "savedUniqueId", uniqueId)

		terraformOptions := &terraform.Options{

			TerraformDir: terraformDir,

			VarFiles: []string{"../../tests/test.vars"},

			Vars: map[string]interface{}{
				// Since this is a non-generic module, the name is fixed, so we'll
				// randomize the environment name to avoid collisions
				"environment": uniqueId,
				"region":      gcpRegion,
			},

			NoColor: true,
		}

		test_structure.SaveTerraformOptions(t, terraformDir, terraformOptions)
	})

	// This defers until all other test steps below either complete or fail
	defer test_structure.RunTestStage(t, "teardown", func() {

		terraformOptions := test_structure.LoadTerraformOptions(t, terraformDir)

		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "setup_deploy", func() {

		terraformOptions := test_structure.LoadTerraformOptions(t, terraformDir)

		output := terraform.InitAndPlan(t, terraformOptions)

		assert.Contains(t, output, "0 to destroy")

		terraform.InitAndApply(t, terraformOptions)

	})

	test_structure.RunTestStage(t, "push_event", func() {
		// Pushes a dummy event: 'test_event.json' to the pubsub topic
		// ideally logwarden should emit an event on its webhook

		ctx := context.Background()

		terraformOptions := test_structure.LoadTerraformOptions(t, terraformDir)

		topicName := terraform.Output(t, terraformOptions, "topic_name")
		projectId := test_structure.LoadString(t, terraformDir, "projectId")

		client, err := pubsub.NewClient(ctx, projectId)

		if err != nil {
			log.Fatalf("Failed to create client: %v", err)
		}

		t := client.Topic(topicName)

		eventMessage, _ := ioutil.ReadFile("../tests/test_event.json")

		result := t.Publish(ctx, &pubsub.Message{
			Data: []byte(eventMessage),
		})

		// iterate 5 times so it's not lost in noise in stackdriver
		for i := 0; i < 5; i++ {

			id, err := result.Get(ctx)

			if err != nil {
				log.Fatalf("Failed to publish: %v", err)
			}

			log.Printf("Published message; msg ID: %v\n", id)

			time.Sleep(2 * time.Second)
		}

	})
}
