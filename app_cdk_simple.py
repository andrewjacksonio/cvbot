#!/usr/bin/env python3
import aws_cdk as cdk
from career_bot.career_bot_stack_simple import CareerBotStackSimple

app = cdk.App()

# Account and region configuration
account = "097890748571"
region = "us-west-2"

# Simple stack without custom domain for testing
CareerBotStackSimple(
    app, 
    "CareerBotStackSimple",
    env=cdk.Environment(account=account, region=region)
)

app.synth()
