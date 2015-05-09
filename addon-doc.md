[let-it-drain](http://addons.heroku.com/let-it-drain) is an add-on for providing functionality X.

Adding functionality X to an application provides benefits X, Y and Z. [[Sell the benefits here! Don't skimp - developers have many options these days.]]

let-it-drain is accessible via an API and has supported client libraries for [[Java|Ruby|Python|Node.js|Clojure|Scala|PHP]]*.

## Provisioning the add-on

let-it-drain can be attached to a Heroku application via the  CLI:

> callout
> A list of all plans available can be found [here](http://addons.heroku.com/let-it-drain).

```term
$ heroku addons:create let-it-drain
-----> Adding let-it-drain to sharp-mountain-4005... done, v18 (free)
```

Once let-it-drain has been added a `LET_IT_DRAIN_URL` setting will be available in the app configuration and will contain the [[variable purpose, i.e. "canonical URL used to access the newly provisioned let-it-drain service instance."]]. This can be confirmed using the `heroku config:get` command.

```term
$ heroku config:get LET_IT_DRAIN_URL
https://let-it-drain.herokuapp.com:443/drain/resourceid
```

After installing let-it-drain the application should be configured to fully integrate with the add-on.

## Local setup

### Environment setup

[[If running against the add-on service during development is not applicable this section can be omitted]]

After provisioning the add-on it’s necessary to locally replicate the config vars so your development environment can operate against the service.

Use [Foreman](config-vars#local-setup) to configure, run and manage process types specified in your app’s [Procfile](procfile). Foreman reads configuration variables from a `.env` file. Use the following command to add the LET_IT_DRAIN_URL values retrieved from heroku config to `.env`.

```term
$ heroku config:get LET_IT_DRAIN_URL -s  >> .env
```

> warning
> Credentials and other sensitive configuration values should not be committed to source-control. In Git exclude the `.env` file with: `echo .env >> .gitignore`.

### Service setup

[[If there is a local executable required (like for the memcache add-on) then include installation instructions. If not, omit entire section]]

let-it-drain can be installed for use in a local development  environment.  Typically this entails [[installing the software | creating another version of the service]] and pointing the LET_IT_DRAIN_URL to this [[local | remote]] service.

<table>
  <tr>
    <th>If you have...</th>
    <th>Install with...</th>
  </tr>
  <tr>
    <td>Mac OS X</td>
    <td style="text-align: left"><code>brew install X</code></td>
  </tr>
  <tr>
    <td>Windows</td>
    <td style="text-align: left">Link to some installer</td>
  </tr>
  <tr>
    <td>Ubuntu Linux</td>
    <td style="text-align: left"><code>apt-get install X</code></td>
  </tr>
  <tr>
    <td>Other</td>
    <td style="text-align: left">Link to some raw package</td>
  </tr>
</table>

## Using with Rails 3.x

[[Repeat this ##Rails 3.x sections for all other supported languages/frameworks including Java, Node.js, Python, Scala, Play!, Grails, Clojure. Heroku is a polyglot platform - don't box yourself into supporting a single language]]

Ruby on Rails applications will need to add the following entry into their `Gemfile` specifying the let-it-drain client library.

```ruby
gem 'let-it-drain'
```

Update application dependencies with bundler.

```term
$ bundle install
```

[[Describe briefly how to use/integrate your service from Rails 3.x with code samples]]

## Using with Python/Django

[[Repeat structure from Rails 3.x section]]

## Using with Java, Node....

[[Repeat structure from Rails 3.x section for each supported language]]

## Monitoring & Logging

Stats and the current state of let-it-drain can be displayed via the CLI.

```term
$ heroku let-it-drain:command
example output
```

let-it-drain activity can be observed within the Heroku log-stream by [[describe add-on logging recognition, if any]].

```term
$ heroku logs -t | grep 'let-it-drain pattern'
```

## Dashboard

> callout
> For more information on the features available within the let-it-drain dashboard please see the docs at [mysite.com/docs](mysite.com/docs).

The let-it-drain dashboard allows you to [[describe dashboard features]].

The dashboard can be accessed via the CLI:

```term
$ heroku addons:open let-it-drain
Opening let-it-drain for sharp-mountain-4005…
```

or by visiting the [Heroku Dashboard](https://dashboard.heroku.com/apps) and selecting the application in question. Select let-it-drain from the Add-ons menu.

## Troubleshooting

If [[feature X]] does not seem to be [[common issue Y]] then 
[[add specific commands to look for symptoms of common issue Y]].

## Migrating between plans

> note
> Application owners should carefully manage the migration timing to ensure proper application function during the migration process.

[[Specific migration process or any migration tips 'n tricks]]

Use the `heroku addons:upgrade` command to migrate to a new plan.

```term
$ heroku addons:upgrade let-it-drain:newplan
-----> Upgrading let-it-drain:newplan to sharp-mountain-4005... done, v18 ($49/mo)
       Your plan has been updated to: let-it-drain:newplan
```

## Removing the add-on

let-it-drain can be removed via the  CLI.

> warning
> This will destroy all associated data and cannot be undone!

```term
$ heroku addons:destroy let-it-drain
-----> Removing let-it-drain from sharp-mountain-4005... done, v20 (free)
```

Before removing let-it-drain a data export can be performed by [[describe steps if export is available]].

## Support

All let-it-drain support and runtime issues should be submitted via one of the [Heroku Support channels](support-channels). Any non-support related issues or product feedback is welcome at [[your channels]].