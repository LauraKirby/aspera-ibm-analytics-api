# Setup

1. Generate private and public keys

<div class="demo-image">
  <img src="images/2-generate-keys.png"/>
</div>

1. You should see the keys in the newly created files.

<div class="demo-image">
  <img src="images/3-preview-private-key.png"/>
</div>

1. Configure the public key for openssl

<div class="demo-image">
  <img src="images/4-configure-jwt-for-openssl.png"/>
</div>

1. In the "Admin" app of AoC, create a new "Integration"

<div class="demo-image">
  <img src="images/5-integrations-create-new.png"/>
</div>

1. Here is what the "new" form will look like

<div class="demo-image">
  <img src="images/6-new-form.png"/>
</div>

1. Fill out form, for the purpose of the Analytics API, the "Redirect URIs" and "Orgins" can be any random value. Click "Save".

<div class="demo-image">
  <img src="images/7-new-form-filled-out.png"/>
</div>

1. You should now be looking at your "Profile".

<div class="demo-image">
  <img src="images/8-profile-details.png"/>
</div>

1. Click on the submenu "JSON Web Token Auth".

<div class="demo-image">
  <img src="images/9-jwt-landing.png"/>
</div>

1. Make the following selections to permit authentication (double check this, may not need to grant as much access).

<div class="demo-image">
  <img src="images/10-jwt-selections.png"/>
</div>

1. Make the additional following selections to permit authentication (double check this, may not need to grant as much access).

<div class="demo-image">
  <img src="images/11-jwt-selections-continued.png"/>
</div>

1. Confirm that you would like to permit global keys.

<div class="demo-image">
  <img src="images/12-allow-global-keys.png"/>
</div>

1. Add your public JWT (generated in step 3) to the field titled "Public Key (PEM Format)".

<div class="demo-image">
  <img src="images/13-copy-public-key.png"/>
</div>

1. Back in terminal, create an empty `.config.yml` file.

<div class="demo-image">
  <img src="images/14-create-empty-config.png"/>
</div>

1. Use the submenu to vist your integration "Profile". Use the keys that I have listed in the `config.yml` file; however, update the values with information that is specific to you.

<div class="demo-image">
  <img src="images/15-add-config-data.png"/>
</div>
