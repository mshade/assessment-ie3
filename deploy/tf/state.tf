terraform {
  cloud {
    organization = "mshade"

    workspaces {
      name = "taskly"
    }
  }
}

