NAME := sbstjn-layers
AWS_REGION ?= eu-central-1
AWS_BUCKET := $(NAME)-artifacts

PATH_SPECS := ./specs/
LIST_SPECS := $(subst $(PATH_SPECS),,$(wildcard $(PATH_SPECS)*))

MAKEFLAGS += --no-print-directory

configure:
	@ aws s3api create-bucket \
		--profile $(AWS_PROFILE) \
		--region $(AWS_REGION) \
		--bucket $(AWS_BUCKET) \
		--create-bucket-configuration LocationConstraint=$(AWS_REGION)

clean-%: DIST=./dist/$*
clean-%:
	@ rm -rf $(DIST)

build-%: SPEC=./specs/$*
build-%: DIST=./dist/$*
build-%:
	@ echo "Running $(SPEC) in $(DIST)"
	@ $(MAKE) clean-$*
	@ mkdir -p $(DIST)
	@ cp $(SPEC)/build.sh $(DIST)/build.sh
	@ cd $(DIST) && ./build.sh
	@ rm $(DIST)/build.sh

archive-%: DIST=./dist/$*
archive-%: 
	@ cd $(DIST) && zip -q -r archive.zip ./*

package-%: DIST=./dist/$*
package-%:
	@ cp cfn.yml $(DIST)/cfn.yml
	@ aws cloudformation package \
		--profile $(AWS_PROFILE) \
		--region $(AWS_REGION) \
		--template-file $(DIST)/cfn.yml \
		--s3-bucket $(AWS_BUCKET) \
		--output-template-file $(DIST)/stack.yml

deploy-%: SPEC=./specs/$*
deploy-%: DIST=./dist/$*
deploy-%:
	@ aws cloudformation deploy \
		--profile $(AWS_PROFILE) \
		--region $(AWS_REGION) \
		--template-file $(DIST)/stack.yml \
		--capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
		--stack-name $(NAME)-$* \
		--no-fail-on-empty-changeset \
		--parameter-overrides \
			Name=$* \
			Description="AWS Lambda Layer for $*" \
			Runtimes="`cat $(SPEC)/data.json| jq '.Runtimes' -r`" \
			License="MIT"

describe-%:
	@ aws cloudformation describe-stacks \
		--profile $(AWS_PROFILE) \
		--region $(AWS_REGION) \
		--stack-name $(NAME)-$* \
			$(if $(value QUERY), --query "$(QUERY)",) \
			$(if $(value FORMAT), --output "$(FORMAT)",)

arn-%:
	@ QUERY="(Stacks[0].Outputs[?OutputKey=='Layer'].OutputValue)[0]" \
		FORMAT=text \
		$(MAKE) describe-$*

publish-%:
	@ $(MAKE) build-$*
	@ $(MAKE) archive-$*
	@ $(MAKE) package-$*
	@ $(MAKE) deploy-$*
	@ $(MAKE) output-$*

output-%:
	@ echo "##### $*\n\``$(MAKE) arn-$*`\`" >> README.md

empty-readme:
	@ rm README.md
	@ cp README.md.base README.md

publish:
	@ $(MAKE) empty-readme
	@ $(MAKE) $(foreach SPEC,$(LIST_SPECS),publish-$(SPEC))
