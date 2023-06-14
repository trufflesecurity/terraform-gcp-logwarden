package test

import (
	"context"
	"fmt"
	"io"
	"log"
	"math/rand"
	"os"
	"testing"
	"time"

	"cloud.google.com/go/storage"
	"github.com/gruntwork-io/terratest/modules/gcp"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestLogwardenModule(t *testing.T) {
	//Basic module tests

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

	terraformDir := "../examples/gcp-auditor"

	test_structure.RunTestStage(t, "setup", func() {

		gcpRegion := gcp.GetRandomRegion(t, "id", approvedRegions, nil)

		// randomize with a unique seed for each test run to avoid name collisions
		rand.Seed(time.Now().UnixNano())
		uniqueId := fmt.Sprintf("%d", rand.Intn(9999))

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

	test_structure.RunTestStage(t, "upload_policy", func() {

		ctx := context.Background()

		terraformOptions := test_structure.LoadTerraformOptions(t, terraformDir)

		// This has to be a defined output in the module
		bucketName := terraform.Output(t, terraformOptions, "policy_bucket_name")

		// Path to a rego policy
		filePath := "../tests/policy/gcp/mitre_privilege_escalation.rego"

		// Create a client
		client, err := storage.NewClient(ctx)
		if err != nil {
			log.Fatalf("Failed to create client: %v", err)
		}

		// Open the file
		f, err := os.Open(filePath)
		if err != nil {
			log.Fatalf("Failed to open file: %v", err)
		}
		defer f.Close()

		// Get a handle to the bucket and the object
		bkt := client.Bucket(bucketName)
		obj := bkt.Object("mitre_privilege_escalation.rego")

		// Write the file to the bucket
		wc := obj.NewWriter(ctx)
		if _, err := io.Copy(wc, f); err != nil {
			log.Fatalf("Failed to copy file: %v", err)
		}
		if err := wc.Close(); err != nil {
			log.Fatalf("Failed to close: %v", err)
		}
	})
}
