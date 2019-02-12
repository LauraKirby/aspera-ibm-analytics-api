This tutorial takes you through the necessary setup to prepare your local system and Aspera on Cloud (AoC) so you can make API calls to the AoC Activity application. We will configure your system and AoC platform, set up the dependencies, make a request to the Files API to obtain authentication, and make authorized requests to the Analytics API. 

**Note**: You will see references to the "Files API", which you use to configure the Aspera on Cloud platform.

## Prerequisites

You must be an administrative user, and you must be added as a member in your Aspera on Cloud (AoC) organization.
1. To confirm that you are a member, open the Admin app in AoC.
1. In the left navigation menu, click **Users**.
1. Look for your name in the list on the Users page.
1. If your name is not there, click **Create new**, then enter your email address and click **Save**.

## Dependencies

The following examples were created using a Mac and Ruby 2.4.1.

* Ruby 2.4.1
* Ruby gem manager (eg [rvm](https://rvm.io/))
* [Bundler 2.0.1](https://bundler.io/)
  * Check to see if you have "Bundler" installed by running `bundler -v` in terminal.

## Getting Started 

[1. Configuring Your System and Application](./setup.md)

[2. Installing Dependencies](./dependencies.md)

[3. Obtaining Files API Authentication](./authentication.md)

[4. Making a Request to the Activity API](./analytics-api.md)

View the source code on Github: [analytics_api_demo](https://github.com/LauraKirby/aspera-ibm-analytics-api/tree/master/analytics-api-demo)
