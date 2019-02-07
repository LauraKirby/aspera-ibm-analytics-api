# System and Application Setup

This page take you through the necessary setup to prepare your local system and Aspera on Cloud (AoC) so that you can make API calls to the Activity app.

There are two main procedures:

  > I. Obtain the necessary elements for authorization

  > II. Configure an integration with AoC


## I. Obtain the necessary elements for authorization

1. In terminal, create a directory with a useful name, such as `analytics-api-demo`, to hold all the required files for this procedure:

    ```bash
    mkdir analytics-api-demo
    cd analytics-api-demo
    touch get_analytics_data.rb authentication.rb get_organization.rb constants.rb Gemfile
    ```

1. Generate private and public keys:

    All files created containing security information such as the private and public keys should not be checked into git. They have been shown here and can be found in the source code for the purpose of demonstration. All keys shown are no longer valid.

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

1. Go to *.ibmaspera.com (* indicates the subdomain for your organization in Aspera on Cloud). 
   
   Click the dropdown next to the **Organization** menu category and click **Integrations**. Click **Create New**.
    <div class="demo-image">
     <img src="images/5-integrations-create-new.png"/>
    </div>


1. Enter a name for your integration.

   Next, enter values for the **Redirect URIs** and **Origins**, which for the purposes of the Activity API can be any value. Press Enter to confirm each one.  After you confirm the value, it appears under a **Name** header.

    <div class="demo-image">
     <img src="images/7-new-form-filled-out.png"/>
    </div>

   When done, click **Save**.

   You now see a newly created **Profile** for your integration.

    <div class="demo-image">
     <img src="images/8-profile-details.png"/>
    </div>

1. Click the submenu **JSON Web Token Auth** (next to **Profile**).

1. Select the check-box for **Enable JWT grant type**.
1. From the **Allowed keys** dropdown, select **User-specific keys and global key**.

    <div class="demo-image">
     <img src="images/11-jwt-selections-continued.png"/>
    </div>

1. In the popup that appears, click **Yes** to confirm that you want to permit global keys.

    <div class="demo-image">
     <img src="images/12-allow-gloabl-keys.png"/>
    </div>

1. A field called **Public Key (PEM Format)** now appears. Enter the key found in `analytics-api-demo/*.key.public` (which you created in step 3).

    <div class="demo-image">
     <img src="images/13-copy-public-key.png"/>
    </div>

1. Click **Save**.

1. In terminal, create an empty `.config.yml` file:

    ```bash
    touch config.yml
    ```

     <div class="demo-image">
       <img src="images/14-create-empty-config.png"/>
     </div>

1. Add content to `config.yml`.

   In the AoC Admin application, open your integration profile: click the **Organization** menu category and click **Integrations**, then click the name of the integration you created.

   <div class="demo-image">
       <img src="images/15-add-config-data.png"/>
      </div>

   Some of the values you need to enter in `config.yml` can be found on this **Profile** page. (These values are noted in the table below.)

   Enter key:value pairs in the file, as in the example below. Replace the example values with values that are specific to your organization.

   ```environment: rad
   client_id: your_client_id
   client_secret: client_secret
   useremail: myemailn@us.company.com
   organization_id: 13330
   organization_name: spire```

 **Where to find the values for `config.yml`:**

| Key | Value |
| --- | --- |
| `environment`| The first element in your organization's URL |
| `client_id` | Found in the "Client info" section on the *Integrations > Profile* page |
| `client_secret` | Found in the "Client info" section on the *Integrations > Profile* page |
| `useremail` | Your email address |
| `organization_id` | The ID for your organization in Aspera on Cloud. If you do not know your organization id, see the API call within [get_organization.rb](https://github.com/LauraKirby/aspera-ibm-analytics-api/blob/master/analytics-api-demo/get_organization.rb) |
| `organization_name` | The subdomain in your organization's URL |

Now that you have completed the setup process, visit [API Requests](./analytics-api.md) to learn about making requests to the Analytics API.
