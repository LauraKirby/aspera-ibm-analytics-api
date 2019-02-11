# System and Application Setup

This tutorial takes you through the necessary setup to prepare your local system and Aspera on Cloud (AoC) so that you can make API calls to the Activity app.

There are two main procedures:

  > I. Obtain the necessary elements for authorization

  > II. Configure an integration with AoC

**Prerequisite:**
You must be an admin user, and you must be added as a member in your Aspera on Cloud (AoC) organization. 
1. To confirm that you are a member, open the Admin app in AoC. 
1. In the left navigation menu, click **Users**. 
1. Look for your name in the list on the Users page.
1. If your name is not there, click **Create new**, then enter your email address and click **Save**.

## I. Obtain the necessary elements for authorization

1. In terminal, create a directory with a useful name, such as `analytics-api-demo`, to hold all the required files for this procedure:

    ```bash
    mkdir analytics-api-demo
    cd analytics-api-demo
    touch get_analytics_data.rb authentication.rb get_organization.rb constants.rb Gemfile
    ```
<!-- Jonathan Solomon: "authentication.rb doesn't return a token (as shown in the guide)" CB asks, where? -->
1. Generate private and public keys:

    <!-- Don't know what this paragraph means: -->All files created containing security information such as the private and public keys should not be checked into git. They have been shown here and can be found in the source code for the purpose of demonstration. All keys shown are no longer valid.

    ```bash
    ssh-keygen -t rsa -b 4096 -m PEM -f jwtRS256.key
    ```

    A prompt, `Enter passphrase (empty for no passphrase)` appears.
    
    To create a key without a passphrase, press Enter twice.

    If the process is successful, your new directory `analytics-api-demo` contains two key files, one private (`.key`) and one public (`.key.public`).

    The image below displays the expected terminal output and an example private key.

    <div class="demo-image">
     <img src="images/3-preview-private-key.png"/>
    </div>

   Note that for all subsequent processes in terminal, you must navigate to the directory created above.

1. Configure the public key to work with OpenSSL:

    ```bash
    openssl rsa -in jwtRS256.key -pubout -outform PEM -out jwtRS256.key.pub
    ```

     <div class="demo-image">
       <img src="images/4-configure-jwt-for-openssl.png"/>
     </div>

## II. Create an integration with AoC

<!-- Jonathan Solomon: remove "qa" from all sample URLs, including screenshots; it's confusing. -->

1. Go to `*.ibmaspera.com`, where `*` represents your subdomain. Your subdomain will be unique to your organization in Aspera on Cloud. In this tutorial `turbo` is used as the subdomain. 

<div class="demo-image">
     <img src="images/5-integrations-create-new.png"/>
    </div>

   Click the dropdown next to the **Organization** menu category and click **Integrations**. Click **Create New**.
    
   An new integration form opens.
   
<div class="demo-image">
     <img src="images/6-new-form.png"/>
    </div>
    
1. Fill out the form with appropriate values for your integration.

   * Enter a name for your integration.

   * Enter values for the **Redirect URIs** and **Origins**. A redirect URI redirects from your domain to a different URL.and the origin is a combination of a specific hostname, protocol, and port on your site, which can be shared by multiple URLs. <!-- Get better examples for this. What does this mean?: "which for the purposes of the Activity API can be any value." --> Press Enter to confirm each one. After you confirm the value, it appears under a **Name** header.

    <div class="demo-image">
     <img src="images/7-new-form-filled-out.png"/>
    </div>

   When done, click **Save**.

   You now see a newly created **Profile** for your integration.

    <div class="demo-image">
     <img src="images/8-profile-details.png"/>
    </div>

1. To update your integration to permit JWT authentication, do the following: 
    * Click the submenu **JSON Web Token Auth** (next to **Profile**).
    * Select the check-box for **Enable JWT grant type**.
    * From the **Allowed keys** dropdown, select **User-specific keys and global key**.

    <div class="demo-image">
     <img src="images/11-jwt-selections-continued.png"/>
    </div>

    In the pop-up that appears, click **Yes** to confirm that you want to permit global keys.

    <div class="demo-image">
     <img src="images/12-allow-gloabl-keys.png"/>
    </div>

    A field called **Public Key (PEM Format)** now appears. Copy the key found in `analytics-api-demo/*.key.public` (which you created in step 3). Include the text, `-----BEGIN PUBLIC KEY------`` and -----END PUBLIC KEY------`.
 
    <div class="demo-image">
     <img src="images/13-copy-public-key.png"/>
    </div>

   Click **Save**.

   Keep this page open.

1. <!-- We're missing something here - did the "touch config.yml" step get deleted? --> Add the constants (for example, `ORGANIZATION_NAME` ) listed below; however, update the values with information that is specific to you (for example, `'my-company-name'`). 

  
   ```CLIENT_ID = BNMWnBP3Rg
   CLIENT_SECRET = 'RpRQHCCzLOMsFo7pyCegd2W58FxmWKep'
   USER_EMAIL = 'laurakirby26@gmail.com'
   ORGANIZATION_ID = 13355
   ORGANIZATION_NAME = 'turbo'
   ```

   You will need to copy information from your integration's Profile page. 
   
   <div class="demo-image">
       <img src="images/15-add-config-data.png"/>
      </div>

    **Where to find the values:**

    | Key | Value |
    | --- | --- |
    | `CLIENT_ID` | Found in the "Client info" section on the *Integrations > Profile* page |
    | `CLIENT_SECRET` | Found in the "Client info" section on the *Integrations > Profile* page |
    | `USER_EMAIL` | Your email address |
    | `ORGANIZATION_ID` | The ID for your organization in Aspera on Cloud. If you do not know your organization ID, see the API call within [get_organization.rb](https://github.com/LauraKirby/aspera-ibm-analytics-api/blob/master/analytics-api-demo/get_organization.rb) **Note**: You may need to install byebug to make the call to the endpoint. <!-- Note from Jonathan Solomon -->|
    | `ORGANIZATION_NAME` | The subdomain in your organization's URL |

Now that you have completed the setup process, visit [API Requests](./analytics-api.md) to learn about making requests to the Analytics API.
