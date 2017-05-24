# Recipes

An example of simple REST-like service built with Elixir and Phoenix.

## Run

1. Install language dependencies
    1. Recommended: [`asdf`](https://github.com/asdf-vm/asdf)
    2. erlang=19.3
    3. elixir=1.4.4
2. Install elixir dependencies: `mix deps.get`
3. Run server: `mix phx.server`

Server is now running on `localhost:4000`.

## Endpoints

The following REST-like API is available:

- `GET /rest/recipes` - fetch a list of available recipes
    - Params
        - `cuisine`: string, filter on cuisine
        - `page_size`: integer, size of page to return, default=2
        - `cursor`: opaque value, use `next` param from response to fetch the next page
    - Returns `{data: [recipe], next: url}`
- `GET /rest/recipes/:id` - fetch a single recipe
    - Returns `{data: recipe}`
- `POST /rest/recipes` - create a new recipe
    - Fields:
        - `box_type`: string, required
        - `title`: string, required
        - `slug`: string, required
        - `marketing_description`: string, required
        - `calories_kcal`: integer, required
        - `protein_grams`: integer, required
        - `fat_grams`: integer, required
        - `carbs_grams`: integer, required
        - `recipe_diet_type_id`: string, required
        - `season`: string, required
        - `protein_source`: string, required
        - `preparation_time_minutes`: integer, required
        - `shelf_life_days`: integer, required
        - `equipment_needed`: string, required
        - `origin_country`: string, required
        - `recipe_cuisine`: string, required
        - `bulletpoints`: list of strings
        - `gousto_reference`: integer, required
        - `short_title`: string
        - `base`: string
        - `in_your_box`: list of strings
    - Returns `{data: recipe}`
- `PUT /rest/recipes/:id` - update a recipe
    - See POST fields above
    - Returns `{data: recipe}`
- `GET /rest/recipes/:recipe_id/ratings` - get customer ratings for recipe
    - Returns `{data: {customer_id: rating}}`
- `GET /rest/recipes/:recipe_id/ratings/:customer_id` - get a customer rating for recipe
    - Returns `{data: rating}`
- `PUT /rest/recipes/:recipe_id/ratings/:customer_id` - set a customer rating for recipe
    - Fields
        - `rating`, integer, required
    - Returns `{data: rating}`

All endpoints that return a recipe object also accept a `fields` param to limit the fields returned in the response.
If `fields` is ommitted, all fields are returned.

## GraphQL

For comparison to the REST-like custom HTTP interface, I've also provided a GraphQL endpoint.

Calls can be sent using `POST` to `/graphql`.

Use [GraphiQL](https://github.com/graphql/graphiql) to introspect the schema.

## Discussion

### Why Elixir/Phoenix?

I like Elixir.

None of the real benefits of Elixir shine through here so it could just as easily be written in any language.

Though being able to just keep the data stored in a process made things easy.

Phoenix does provide nice helpers around routing, but I didn't really leverage a lot of it's functionality e.g. views.

### Data Store

Everything is stored in memory because serializing the data to disk was outside the scope of this project.

### REST-like?

I believe debating over what's "RESTful" or not is the epitome of engineer bikeshedding.

Should I have returned a different status code here or formatted my errors differently there? Perhaps.

The thing is, despite the fact that e.g. Twitter has a "REST" API, you will still find a twitter-sdk library in every language, because REST is not a protocol.

IMO, REST has it's place: if you are an owner of some structured data and you want to provide it to some external users but you have no idea how they are going to access it, by all means use REST.

But if you control both ends of the socket... RPC-over-HTTP can often do the job without all the fuss.

### Differing needs of consumers

Mobile clients could leverage the `page_size` and `fields` params to limit bandwidth usage.

However the GraphQL schema is more flexible if the data graph complexity were to increase.

### Improvements

A few things that could be interesting:

- Make it Swagger compatible for better documentation (tooling is actually one of the places where REST can be useful... but if you have to write a schema anyway...)
- Use Ecto.Changesets instead of my the hand-rolled param Validation.

