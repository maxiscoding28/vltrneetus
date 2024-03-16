package main

import (
	"log"
	"os/exec"
	"path/filepath"

	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/clientcmd"
	"k8s.io/client-go/util/homedir"
)

type MinikubeStatus struct {
	Type       string `json:"type"`
	Host       string `json:"host"`
	Kubelet    string `json:"kubelet"`
	Apiserver  string `json:"apiserver"`
	Kubeconfig string `json:"kubeconfig"`
}

const redColor = "\033[31m"
const resetColor = "\033[0m"

func logError(message string) string {
	return redColor + message + resetColor
}

func minikubeIsRunning(err error) bool {
	if err != nil {
		exitErr, ok := err.(*exec.ExitError)
		if ok && exitErr.ExitCode() == 7 {
			log.Fatalf(logError("Minikube is stopped: %v"), err)
		} else {
			log.Fatalf("Error running minikube status command: %v", err)
		}
		return false
	}
	return true
}

func createK8sConfig() (*kubernetes.Clientset, error) {
	cfg, _ := clientcmd.BuildConfigFromFlags("", filepath.Join(homedir.HomeDir(), ".kube", "config"))
	return kubernetes.NewForConfig(cfg)
}

func createProjectNamespace() {
	// Does vltrneetus namespace exist?
	// If it does
	// Prompt user to oveerwrite
	// If yes to overwrite delete namespace
	// If no then exit program
	// Create namespace in k8s
}

func createTLSFiles() {

}

func createDeployment() {

}

func initializeVault() {

}

func configureVault() {

}

func resetCluster() {

}

func main() {
	_, err := exec.Command("minikube", "status", "-o", "json").Output()
	if minikubeIsRunning(err) {
		log.Println("Initializing cluster...")

		// k8sClient, _ := createK8sConfig()

		// createProjectNamespace

		// Create TLS cluster in Vault

		// Commands to Do Different Things Like
		// Reset Cluster
		// Deploy a Vault Agent Injector
		// Deploy an Ingress
		// Deploy a VSO
		// Deploy a CSI
		// Set up HSM
		// Set up Metrics
		// Deploy to AKS/EKS

		// Connect External Vault to Internal Resources
		// Agent, VSO, CSI, Direct Request

	}
}
