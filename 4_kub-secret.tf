# Generate private/public RSA keys
# This is required for integration with Google sheets

# Run openssl commands on 'local' machine used to run this terraform script
resource "terraform_data" "openssl_execs"{
  provisioner "local-exec" {
          command = "openssl genrsa -out private_key.pem 2048"
  }
  provisioner "local-exec" {
          command = "openssl pkcs8 -topk8 -inform PEM -outform DER -in private_key.pem -out private_key.der -nocrypt"
  }
  provisioner "local-exec" {
          command = "openssl rsa -in private_key.pem -pubout -outform DER -out public_key.der"
  }
}

data "local_file" "public_key" {
  filename = "./public_key.der"
  depends_on = [ terraform_data.openssl_execs ]
}

data "local_file" "private_key" {
  filename = "./private_key.der"
  depends_on = [ terraform_data.openssl_execs ]
}

# Create a Kubernetes secret for private key
resource "kubernetes_secret" "trifacta-credential-encryption" {
  metadata {
    name      = "trifacta-credential-encryption"
    namespace = "default"
  }

  data = {
    privateKey = data.local_file.private_key.content_base64
  }

  depends_on = [module.gke]
}

# Output the base64 public key for configuration in Dataprep
output "public-key" {
  value = data.local_file.public_key.content_base64
}   