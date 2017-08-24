# Desk.com Canvas: Shopify
This a Shopify integration built for Desk.com using Canvas. Note that you will need to be on the Pro or Business Plus pricing plan for Desk.com to use Canvas.

## I. Create a Private App in Shopify
First create a private app in Shopify, which will provide the API keys needed to authorize the application.

1. Navigate to private apps in the admin: https://your-shopify-domain.myshopify.com/admin/apps/private, replacing "your-shopify-domain" with your actual shopify domain.

2. Click **Generate API credentials**.

3. Name your app "Desk.com".

4. Give "Read Access" to the following permissions:

    - Store content like articles, blogs, comments, pages, and redirects 	
    - Customer details and customer groups 	
    - Draft orders 	
    - Orders, transactions and fulfillments 	
    - Product information 
    - Products, variants and collections 

5. Click Save.

6. You should see the API credentials. We'll use the "API Key" and "Password" in the next steps. 

## II. Create the Integration URL
Before we deploy the application on Heroku, we'll need the Canvas key from Desk.

1. Navigate to the integration urls section of the Desk Admin: https://your-desk-domain.desk.com/admin/case-management/integrations

2. Click **Add Integration Url**.

3. In the **Name** field, add a title for the this application. In this example, we’ll use 'Shopify'.

4. The **Description** field, though optional, is a way to give a general description of the integration URL.

5. Select 'Canvas iFrame' from the **Open Location** dropdown.

6. In the **URL** field, add any valid url as a placeholder. We'll update this later.

7. Toggle the **Enabled** button to 'Yes' and select the [Permission level](https://support.desk.com/customer/portal/articles/1146981?b_id=7112&t=568640).

8. Click the **Add** button.

9. Reopen the new integration url and copy the **Shared Key**.

## III. Deploy the Application
Now that we have all of the proper keys, we can install this application by deploying the source code to your Heroku account. To deploy your application, simply click this button:

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy?template=https%3A%2F%2Fgithub.com%2Fdesklabs%2Fshopify-canvas%2Ftree%2Fmaster)

During the setup, it will ask you to specify the Config Variables.

  - SHOPIFY\_API\_KEY: The API Key from your private app in Shopify.
  - SHOPIFY\_API\_SECRET: The **Password** from your private app in Shopify. Do not use the Shared Secret field. 
  - SHOPIFY\_HOST: This is the custom domain for your shopify site. For example, if your site url is https://your-shopify-domain.myshopify.com, you would enter your-shopify-domain.
  - CANVAS\_KEY: The shared key from your integration url above. 

## IV. Update the Integration URL
Now that you have the application on Heroku, go ahead and update the integration URL in Desk with your heroku app url.

1. Navigate to the integration url page in the Desk admin. Click on the Shopify integration url to edit it. 

2. Enter the heroku app url in the **URL** field. 

3. Click the **Update** button.

## V. Add it to your Case Layout
Now display the canvas application on your Case Layout.

1. **Go to Cases >> Next Gen Case Layouts**

2. Find the **Shopify** canvas application in the **Integrations** section on the right side of the screen.

3. **Drag** and **Drop** the application in your case layout.

4. Scroll over the left side of the 'Shopify' bar and click on the gear to open the **Edit** window. Adjust the pixel **Height** to **200** and **Position**, the order in which it appears in Case Details on the dashboard. Click **Save**.

## VI. Dashboard Confirmation
After you have added the canvas application to your layout and selected users, open a ticket and you should see the Shopify section under **Case Details**.
