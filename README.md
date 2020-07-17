# Common Core Scaffold Builder & Rapid Prototype Developer


Yes, it's a Rails scaffoling builder. Yes, it builds scaffolding quickly and easily. Yes, it's similar to all the other Rails scaffold builders. 

Yes, it's opinionated. Yes, it's metaprogramming. A lot of metaprogramming. Ruby on Ruby. Ruby on Javascript. It's like a whole fun pile of metaprogramming.

No, I would not use this to build an intricate app. Yes, it's a great tool for prototyping. Yes, I think prototyping is a lost art. 


```
rails generate common_core:scaffold Thing 
```

TO INSTALL:

- Add common_core_js to your Gemfile

- Install jQuery (required)

- Install Bootstrap (optional)

- Install Devise or implement your own authentication

- Unless you want to bypass specs, you'll also want Rspec (rspec-rails), factory_bot_rails, and shoulda-matchers
 

## Options

Note that the arguments are not preceeded by dashes and are followed by equal sign and the input you are giving.

Flags take two dashes (--) and do not take any value. 

### First Argument
 
TitleCase class name of the thing you want to build a scaffoling for.

### `namespace=`

pass `namespace=` as a flag to denote a namespace to apply to the Rails path helpers


`rails generate common_core:scaffold Thing namespace=dashboard`

This produces several views at `app/views/dashboard/things/` and a controller at`app/controllers/dashboard/things_controller.rb`

The controller looks like so:

```
class Dashboard::ThingsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_thing, only: [:show, :edit, :update, :destroy]
  def load_thing
    @thing = current_user.things.find(params[:id])
  end
  ...
end

```


### `nest=`

pass `nest=` as a flag to denote a nested resources


`rails generate common_core:scaffold Line nest=invoice`

In this example, it is presumed that the current user has_many :invoices, and that invoices have many :lines


For multi-level nesting use slashes to separate your levels of nesting. Remember, you should match what you have in your routes.rb file.

```
resources :invoices do
    resources :lines do
        resources :charge
    end    
end

```
In this example, it is presumed that the current user has_many :invoices, and that invoices have many :lines, and that lines have many :charges


To generate scaffold: 
 `rails generate common_core:scaffold Charge nest=invoice/line`

The order of the nest should match the nested resources you have in your own app.  In particular, you auth root will be used as the starting point when loading the objects from the URL:

In the example above, @invoice will be loaded from

`@invoice = current_user.invoices.find(params[:invoice_id])`

Then, @line will be loaded

`@line = @invoice.lines.find(params[:line_id])`

Then, finally the @charge will be loaded

`@charge = @line.charges.find(params[:id])`

It's called "poor man's auth" because if a user attempts to hack the URL by passing ids for objects they don't own--- which Rails makes relatively easy with its default URL pattern-- they will hit ActiveRecord not found errors (the objects they don't own won't be found in the associated relationship). 

It works, but it isn't granular. As well, it isn't appropriate for a large app with any level of intricacy to access control (that is, having roles). 

Your customers can delete their own objects by default (may be a good idea or a bad idea for you). If you don't want that, you should strip out the delete actions off the controllers. 


### `auth=`

By default, it will be assumed you have a `current_user` for your user authentication. This will be treated as the "authentication root" for the "poor man's auth" explained above.

The poor man's auth presumes that object graphs have only one natural way to traverse them (that is, one primary way to traverse them), and that all relationships infer that a set of things or their descendants are granted access to me for reading, writing, updating, and deleting. 

Of course this is a sloppy way to do authentication, and can easily leave open endpoints your real users shouldn't have access to. 

When you display anything built with the scaffolding, we assume the `current_user` will have `has_many` association that matches the pluralized name of the scaffold. In the case of nesting, we will automatically find the nested objects first, then continue down the nest chain to find the target object. In this way, we know that all object are 'anchored' to the logged-in user. 

If you use Devise, you probably already have a `current_user` method available in your controllers. If you don't use Devise, you can implement it in your ApplicationController.

If you use a different object other than "User" for authentication, override using the `auth` flag. 

 `rails generate common_core:scaffold Thing auth=current_account`

You will note that in this example it is presumed that the Account object will have an association for `things`

It is also presumed that when viewing their own dashboard of things, the user will want to see ALL of their associated things.

If you supply nesting (see below), your nest chain will automatically begin with your auth root object (see nesting)




### `auth_identifier=`

Your controller will call a method authenticate_ (AUTH IDENTIFIER) bang, like:

`authenticate_user!`

Before all of the controller actions. If you leave this blank, it will default to using the variable name supplied by auth with "current_" stripped away. 
(This is setup for devise.)

Be sure to implement the following method in your ApplicationController or some other method. Here's a quick example using Devise. You will note in the code below, user_signed_in? is implemented when you add Devise methods to your User table. 

As well, the `after_sign_in_path_for(user)` here is a hook for Devise also that provides you with after login redirect to the page where the user first intended to go.

```
  def authenticate_user!
    if ! user_signed_in?
      session['user_return_to'] = request.path
      redirect_to new_user_registration_path
    end
  end

  def after_sign_in_path_for(user)
    session['user_return_to'] || account_url(user)
  end
```


The default (do not pass `auth_identifier=`) will match the `auth` (So if you use 'account' as the auth, `authenticate_account!` will get invoked from your generated controller; the default is always 'user', so you can leave both auth and auth_identifier off if you want 'user') 


 `rails generate common_core:scaffold Thing auth=current_account auth_identifier=login` 
 In this example, the controller produced with:
```
   before_action :authenticate_login!
```
However, the object graph anchors would continue to start from current_account. That is,
```
@thing = current_account.things.find(params[:id])
```

Use empty string to **turn this method off**:
 `rails generate common_core:scaffold Thing auth=current_account auth_identifier=''` 

In this case a controller would be generated that would have NO before_action to authenticate the account, but it would still treat the current_account as the auth root for the purpose of loading the objects.

Please note that this example would product non-functional code, so you would need to manually fix your controllers to make sure `current_account` is available to the controller.


### `plural=`

You don't need this if the pluralized version is just + "s" of the singular version. Only use for non-standard plurlizations, and be sure to pass it as TitleCase (as if  you pluralized the model name)


### `--god`

Use this flag to create controllers with no root authentication. You can still use an auth_identifier, which can be useful for a meta-leval authentication to the controoler.

For example, FOR ADMIN CONTROLLERS ONLY, supply a auth_identifier and use --god flag

In God mode, the objects are loaded directly from the base class (these controllers have full access)
```
def load_thing
    @thing = Thing.find(params[:id])
end

```

### `--with-index`

By default no master index views get produced. Use this flag to produce an index view. 

The index views simply include the _list partial but pass them a query to use:

`= render partial: "list", locals: {things: Thing.order("created_at DESC").page(1)}`

You will note that unlike other scaffold you may have seen, the "all" view is found at
```
all.haml
```

Common core generate ONLY this top-level (non-partial) HAML file, relying on Rails partials to do the rest. This lets us get little fancy with reloading and re-rendering, and provides for a smooth consistent starting point for you to customize the views. 

The intention is that you DO NOT generate any all.haml views, because you will probably be building a dashboard that composites several different tables into a single page.

When you do that, load the list views from the build scaffolding to define the different sections of your page

```
= render partial: "dashboard/things/list", locals: {things: current_user.things.order("created_at DESC").page(1)}
```

Because it's rare that you actually want to build a page that is just a list of one table, the index views are not generate by default.


### `--specs-only`

Produces ONLY the controller spec file, nothing else.


### `--no-specs`

Produces all the files except the spec file.





# TROUBLESHOOTING

## NoMethodError in HellosController#index undefined method `authenticate_user!' for #<HellosController:0x00007fcc2decf828> Did you mean? authenticate_with_http_digest
        
--> Install Devise or implement current_user method on your controller or use with auth= and/or auth_identifier= to specify how you want to authenticate your user. 


## Uncaught ReferenceError: $ is not defined
     
--> Install Jquery + Rails UJS
`yarn add jquery`
`yarn add  @rails/ujs`

Add to application.js
```
require("jquery")
```

And add to config/webpack/environment.js

```
const { environment } = require('@rails/webpacker')

const webpack = require('webpack')
environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    $: 'jquery/src/jquery',
    jQuery: 'jquery/src/jquery',
    Rails: ['@rails/ujs']
  })
)

module.exports = environment

```
