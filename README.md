# Common Core Scaffold Builder & Rapid Prototype Develoepr


Yes, it's a Rails scaffoling builder. Yes, it builds scaffolding quickly and easily. Yes, it's similar to all the other Rails scaffold builders. 

Yes, it's opinionated. Yes, it's metaprogramming. A lot of metaprogramming. Ruby on Ruby. Ruby on Javascript. It's like a whole fun pile of metaprogramming.

No, I would not use this to build an intricate app. Yes, it's a great tool for prototyping. Yes, I think prototyping is a lost art. 


```
rails generate common_core:scaffold Thing 
```

## Options

Note that the arguments are not preceeded by dashes and are followed by equal sign and the input you are giving.

Flags take two dashes (--) and do not take any value. 

### First Argument
 
TitleCase class name of the thing you want to build a scaffoling for.

### namespace=

pass `namespace=` as a flag to denote a namespace to apply to the Rails path helpers


`rails generate common_core:scaffold GetEmailsRule namespace=dashboard`

### nest=

pass `nest=` as a flag to denote a nested resources


`rails generate common_core:scaffold Lineitem nest=invoice`

For multi-level nesting use slashes to separate your levels of nesting. Remember, you should match what you have in your routes.rb file.

resources :invoices do
    resources :lines do
        resources :charges
    end    
end


 `rails generate common_core:scaffold Charge nest=invoice/line`
The order of the nest should match the nested resources you have in your own app.  In particular, you auth root will be used as the starting point when loading the objects from the URL:

In the example above, @invoice will be loaded from

@invoice = current_user.invoices.find(params[:invoice_id])

Then, @line will be loaded

@line = @invoice.lines.find(params[:line_id])

Then finally the @charge will be loaded

@charge = @line.charges.find(params[:id])

It's called "poor man's auth" because if a user attempts to hack the URL by passing ids for objects they don't own--- which Rails makes relatively easy with its default URL pattern-- they will hit ActiveRecord not found errros because the objects will not be found in the assocaited relationships. 

It works, but it isn't granular. As well, it isn't appropriate for a large app with any level of intricacy to access control (that is, having roles). 

Your customers can delete their own objects by default (may be a good idea or a bay idea for you). If you don't want that, you should strip out the delete actions off the controllers. 


### auth=

By default, it will be assumed you have a `current_user` for your user authentication. This will be treated as the "authentication root" for what is fundamentally "poor man's auth."

The poor man's auth presumes that object graphs have only one natural way to traverse them (that is, one primary way to traverse them), and that all relationships infer that a set of things or their descendants are granted access to me for reading, writing, updating, and deleting. 

Of course this is a sloppy way to do authentication, and can easily leave open endpoints your real users shouldn't have access to. 

When you display anything built with the scaffolding, we assume the `current_user` will have `has_many` association that matches the pluralized name of the scaffold. In the case of nesting, we will automatically find the nested objects first, then continue down the nest chain to find the target object. In this way, we know that all object are 'anchored' to the logged-in user. 

If you use Devise, you probably already have a `current_user` method available in your controllers. If you don't use Devise, you can implement it in your ApplicationController.

If you use a different object other than "User" for authentication, override using the `auth` flag. 

 `rails generate common_core:scaffold Thing auth=current_account`

You will note that in this example it is presumed that the Account object will have an association for `things`

It is also presumed that when viewing their own dashboard of things, the user will want to see ALL of their associated things.

If you supply nesting (see below), your nest chain will automatically begin with your auth root object (see nesting)




### auth_identifier=

Your controller will call a method authenticate_ (AUTH IDNETIFIER) bang, like:

authenticate_user!

Before all of the controller actions. If you leave this blank, it will default to using the variable name supplied by auth with "current_" stripped away. 
(This is setup for devise.)

Leave blank for default, which is to match the auth. 

 `rails generate common_core:scaffold Thing auth=current_account auth_identifier=login` 
 In this example, the controller produced with have:
   before_action :authenticate_login!


Use empty string to turn this method off:
 `rails generate common_core:scaffold Thing auth=current_account auth_identifier=''` 


### plural=

You don't need this if the pluralized version is just + "s" of the singular version. Only use for non-standard plurlizations, and be sure to pass it as TitleCase (as if  you pluralized the model name)


### --god

Use this flag to create controllers with no root authentication. You can still use an auth_identifier, which can be useful for a meta-leval authentication to the controoler.

For example, FOR ADMIN CONTROLLERS ONLY, supply a auth_identifier and use --god flag

### --with-index

By default no master index views get produced. Use this flag to produce an index view. 

The index views simply include the _list partial but pass them a query to use:

`= render partial: "list", locals: {things: Thing.order("created_at DESC").page(1)}`








# TROUBLESHOOTING

## NoMethodError in HellosController#index undefined method `authenticate_user!' for #<HellosController:0x00007fcc2decf828> Did you mean? authenticate_with_http_digest
    
    
--> Install Devise



## Uncaught ReferenceError: $ is not defined
     
--> Install Jquery. Here's a good link: https://www.botreetechnologies.com/blog/introducing-jquery-in-rails-6-using-webpacker

Be sure to 1) add with Yark, 2) Modify environment.js, 3) Modify application.js



## Nothing happens after you install jQuery

--> Install Rails UJS
`yarn add  @rails/ujs`

And add to config/webpack/environment.js

```
const webpack = require('webpack')
environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    Rails: ['@rails/ujs']
  })
)
module.exports = environment
```
