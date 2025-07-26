#!/usr/bin/env python3
import aws_cdk as cdk
from career_bot.career_bot_stack import CareerBotStack

app = cdk.App()

# Account and region configuration
account = "097890748571"
region = "us-west-2"

CareerBotStack(
    app, 
    "CareerBotStack",
    env=cdk.Environment(account=account, region=region),
    domain_name="cvbot.andrewjackson.io",
    hosted_zone_name="andrewjackson.io"
)

app.synth()
