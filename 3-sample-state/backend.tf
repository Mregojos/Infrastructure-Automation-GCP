terraform {
    backend "gcs" {
        bucket = "2ed447420b2c0648-bucket-tfstate"
        prefix = "terraform/state"
    }
}
