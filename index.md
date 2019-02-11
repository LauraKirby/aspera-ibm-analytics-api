Unofficial documentation for accessing Aspera on Cloud ("AoC") application activity, transfer status and metadata, file access and volume usage.

## Dependencies

The following examples were created using a Mac and Ruby 2.4.1. Note, copying the tokens used within this example will not work (they have been deactivated). You will need to generate tokens of your own.

* Ruby 2.4.1
* Ruby gem manager (eg [rvm](https://rvm.io/))
* [Bundler 2.0.1](https://bundler.io/)
  * Check to see if you have "Bundler" installed by running `bundler -v` in terminal.

## Getting Started

This tutorial takes you through the necessary setup to prepare your local system and Aspera on Cloud (AoC) so that you can make API calls to the AoC Activity application. We will set up the dependencies, make a request to the Files API to obtain authentication, and make authorized requests to the Analytics API. Note that we use the Files API to configure the Aspera on Cloud platform, which includes the Activity application.

[1. System and Application Setup](./setup.md)

[2. Install Dependencies](./dependencies.md)

[3. Obtain Files Application Authentication](./authentication.md)

[4. Make Request to the Analytics API](./analytics-api.md)

> View the source code on Github: [analytics_api_demo](https://github.com/LauraKirby/aspera-ibm-analytics-api/tree/master/analytics-api-demo)
