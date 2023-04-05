package test

import (
	"fmt"
	"math/rand"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/gcp"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestAuditorModule(t *testing.T) {
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
		uniqueId := fmt.Sprintf("terraform-test-%d", rand.Intn(9999))

		test_structure.SaveString(t, terraformDir, "savedGcpRegion", gcpRegion)
		test_structure.SaveString(t, terraformDir, "savedUniqueId", uniqueId)

		terraformOptions := &terraform.Options{

			TerraformDir: terraformDir,

			VarFiles: []string{"../../tests/test.vars"},

			Vars: map[string]interface{}{
				"name":   uniqueId,
				"region": gcpRegion,
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
}
