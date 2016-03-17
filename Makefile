.PHONY: all plan apply destroy

all: plan apply

plan:
	cd terraform && terraform plan

apply:
	cd terraform && terraform apply

destroy:
	cd terraform && terraform destroy
