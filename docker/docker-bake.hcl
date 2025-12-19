group "default" {
  targets = [
    "prusaslicer-web",
  ]
}

target "prusaslicer-base" {
  context = "./prusaslicer-base/"
  args = {
    PRUSASLICER_TAG = "version_2.9.4"
  }
}

target "prusaslicer-web" {
  context = "./prusaslicer-web/"
  contexts = {
    prusaslicer_base = "target:prusaslicer-base"
  }
  depends_on = ["prusaslicer-base"]
  tags = ["prusaslicer-web:dev"]
}
