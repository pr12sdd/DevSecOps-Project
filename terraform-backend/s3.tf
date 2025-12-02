resource "aws_s3_bucket" "mys3bucket" {
    bucket = "mys3bucket402"
    tags={
        Name="mys3bucket402"
    }
    force_destroy=true
}
