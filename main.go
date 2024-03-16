package main

import (
	"context"
	"fmt"
	"log"
	"os/exec"
	"path/filepath"

	v1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"

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
	config, _ := clientcmd.BuildConfigFromFlags("", filepath.Join(homedir.HomeDir(), ".kube", "config"))
	return kubernetes.NewForConfig(config)
}

func createProjectNamespace(client *kubernetes.Clientset) {
	_, getError := client.CoreV1().Namespaces().Get(context.Background(), "v8s", metav1.GetOptions{})
	if getError != nil {
		println(getError.Error())

		if getError.Error() == "namespaces \"v8s\" not found" {
			println("Creating \"v8s\" namespace")
			v8sNamespace := &v1.Namespace{
				ObjectMeta: metav1.ObjectMeta{
					Name: "v8s",
				},
			}
			_, setError := client.CoreV1().Namespaces().Create(context.Background(), v8sNamespace, metav1.CreateOptions{})
			if setError != nil {
				println(setError.Error())
			}
		}
	} else {
		println("Namespace \"v8s\" already exists.Would you like to overwrite it?\n\tY or n")
		var input string
		fmt.Scanln(&input)
		if input == "Y" {
			fmt.Println("Yes")
			// Delete and overwrite
		} else if input == "n" {
			fmt.Println("No")
			// Exit program
		} else {
			fmt.Println("Invalid input")
			// Exit program
		}
	}
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
		k8sClient, _ := createK8sConfig()
		createProjectNamespace(k8sClient)

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
