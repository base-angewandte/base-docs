# API Principles

## RESTful & OpenAPI 3.0

We try to make our APIs as [RESTful](https://en.wikipedia.org/wiki/Representational_state_transfer) as possible, with smaller deviations from the REST principles, when the application domain has specific requirements. In this case the deviation from REST principles MUST be documented and SHOULD be documented within the API itself (see following notes on Open API documentation), but in cases where an external documentation makes more sense, this MAY be linked to in the API instead of replicating the documentation.

In general _base APIs_ MUST use JSON as data format and HTTP methods as operations.

All our APIs MUST be documented in an Open API format, they SHOULD use version 3.0 or higher, whenever possible.

**Examples:**

Many of our backends are built with Django and the django-rest-framework. On top of that we use [drf-spectacular](https://github.com/tfranzel/drf-spectacular) (and we did use [drf-yasg](https://github.com/axnsan12/drf-yasg) before that) to auto-generate an Open API compatible description of the APIs between backend and frontend.

## `/autocomplete` endpoint

If base backend applications provide an autocomplete feature, they SHOULD provide it through an `/autocomplete` endpoint.
If they do, then this endpoint should use a `GET` request with at least the three following query parameters:

- `q`: the query string, for which autocomplete suggestions should be returned
- `type`: the category of items for which autocomplete suggestions should be returned - this depends on the application
  data model, common examples are `users`, `titles`, `keywords`, or `locations`etc. The `type` parameter can either be
  just one type, or a comma-separated list of several types. The output will differ accordingly (see below).
- `limit`: an integer representing a limit to the number of returned results (within each requested `type`)

The response of this endpoint SHOULD look like this:

```json
[
  {
    "id": "<type_id>",
    "label": "<label_for_type>",
    "data": [
      {
        "id": "<id or source>",
        "source_name": "<optional: source_name>",
        "label": "<translated label for this item>"
      }
    ]
  }
]
```

Here the outer list is the list of results for the different requested categories of items (requested with `type`),
while the inner list represents the individual autocomplete suggestions.

Only in those cases where a single `type` has been requested the response SHOULD change to what the `data` property in
the above case would contain for the specific type:

```json
[
  {
    "id": "<id or source>",
    "source_name": "<optional: source_name>",
    "label": "<translated label for this item>"
  }
]
```

## `/user` endpoint

All base backend applications with functionality for authenticated users MUST provide a `/user` endpoint, through which an authenticated user's details can be retrieved.

This endpoint MUST return a 403 with an error message if the user isn't logged in, OR a 200 response with a JSON object containing at least the following properties:

- `id` or `uuid`: the user ID from the organisation's authentication backend
- `name`: the user's name
- `email`: the user's e-mail address
- `groups`: an array containing the groups a user belongs to within the organisation
- `permissions`: an array containing the permissions a user has within the organisation when using base applications

These properties are on the one hand used by the frontend to populate the information displayed in the base header and on the other hand are relevant for the application itself, e.g. `permissions` might determine if the user is allowed to use certain parts of the application or the application itself.

Additionally more application specific properties MAY be added, e.g.:

- an `entity_id` in case of Showroom, to provide the user's ID within Showroom (and for their Showroom page)
- a `space` property in case of Portfolio to signify the available space for uploads

If the application can provide substantially more information related to a user (e.g. aggregated data belonging to the user), a `/user/{id}/data` endpoint MAY be used additionally.

The `/user` (and other relevant) endpoint(s) are protected with a combination of DRFs `permissions.IsAuthenticated` and CAS as the authentication mechanism for login. Therefor for applications that require the user to be logged in, the frontend has to redirect the user to the backend login url `/accounts/login` in case of a `403`. External endpoints MUST be protected through adequate authentication mechanisms, e.g. via an API-Key. Public user data MAY be provided through separate endpoints, ONLY if the user explicitly made this specific information public.

**Examples:**

An example of how the `/user` endpoint works is https://base.uni-ak.ac.at/portfolio/api/v1/user/
The corresponding backend code can be found in Portfolio's [`src/api/views.py` module in the `user_information` function](https://github.com/base-angewandte/portfolio-backend/blob/1.1.2/src/api/views.py#L279)

## Authentication

Our default authentication flow and mechanism is based on Django's session authentication and the CAS protocol. In
practice every base application will use a `sessionid_<appname>` Cookie to identify the user to the app. Additionally
for 'unsafe' HTTP operations (`POST`, `PUT`, `PATCH`, `DELETE`) require a CSRF token. For more background check the
[Working with AJAX, CSRF & CORS](https://www.django-rest-framework.org/topics/ajax-csrf-cors/) page of the Django
REST framework documentation.

So, while any authenticated request against the API will need to provide a `sessionid_<appname>` cookie, any request
that uses an 'unsafe' operation will additionally need a `csrftoken_<appname>` cookie, and also use this token as a
value for an additional `X-CSRFToken` HTTP request header.

In order to get the session cookie and the CSRF token, you need to follow the CAS-based login flow. Every time you log
in, after all successful redirects you will not only receive the `sessionid_<appname>` cookie, but also the
`csrftoken_<appname>` cookie. The default procedure for this authentication flow is:

1. Make a `GET` request on `/accounts/login/` of the application you want to log in. This will return a 302 redirect.
2. Redirect the client to the received CAS url, which includes all required parameters.
3. The user can now log in at the configured CAS authentication backend - this will usually be _baseauth_.
4. After successful log in, CAS will respond with a 302 redirect back to the `/accounts/login/` route of the calling
   application, but with the authentication ticket as a parameter, and also setting the `sessionid_cas` and
   `csrftoken_cas` cookies which are used to support the single-sign-on process over all base applications.
5. Now the application uses the authentication ticket to verify against CAS, that the user has successfully logged in,
   responds again with a 302 redirect to `/` or wherever the login redirect is configured to go to. In this redirect
   the `sessionid_<appname>` and `csrftoken_<appname>` are set. So once your user is logged in, the frontend should
   always be able to get those from the cookies, whenever an API request requires it.

## API namespace

In new projects, our APIs need to be versioned and therefor always have a prefix of `/api/v{major}/`.

## API consumption

- Base frontend projects currently use [axios](https://github.com/axios/axios)
- (**optional**) additionally currently API consumption in Frontend is built around [swagger-client](https://www.npmjs.com/package/swagger-client)
- (**optional**) To be able to test the front end without backend a mock API server is implemented with [Express](https://expressjs.com/) (and optional [openapi-backend](https://github.com/anttiviljami/openapi-backend))

## X-Attributes

In oder to add information to the OpenAPI schema that is not covered by standard OpenAPI specification we use [OpenAPI Extensions](https://swagger.io/docs/specification/openapi-extensions/) or more specifically a custom property `x-attrs`. Mainly the information covered in the `x-attrs` property is used to build forms in front end.

### Use of X-Attributes for Frontend (Form Creation)

The creation of forms via [available components](https://base-angewandte.github.io/base-ui-components/), namely [BaseForm](https://base-angewandte.github.io/base-ui-components/#baseform) and [BaseFormFieldCreator](https://base-angewandte.github.io/base-ui-components/#baseformfieldcreator) relies on x-attributes within the OpenAPI specification.

`type` or `field_type` in the context below means the following components are utilized:

| type         | component                                                                                                                                                                                                                                                                                                                                                                    |
| ------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| text         | [BaseInput](https://base-angewandte.github.io/base-ui-components/#baseinput)                                                                                                                                                                                                                                                                                                 |
| autocomplete | [BaseAutocompleteInput](https://base-angewandte.github.io/base-ui-components/#baseautocompleteinput)                                                                                                                                                                                                                                                                         |
| chips        | [BaseChipsInput](https://base-angewandte.github.io/base-ui-components/#basechipsinput)                                                                                                                                                                                                                                                                                       |
| chips-below  | [BaseChipsBelow](https://base-angewandte.github.io/base-ui-components/#basechipsbelow)                                                                                                                                                                                                                                                                                       |
| date         | [BaseDateInput](https://base-angewandte.github.io/base-ui-components/#basedateinput)                                                                                                                                                                                                                                                                                         |
| multiline    | [BaseMultilineTextInput](https://base-angewandte.github.io/base-ui-components/#basemultilinetextinput)                                                                                                                                                                                                                                                                       |
| group        | this will create a subform in a [BaseForm](https://base-angewandte.github.io/base-ui-components/#baseform) and is used for nested field groups (for an example of such grouped fields see [BaseForm](https://base-angewandte.github.io/base-ui-components/#baseform) or [BaseFormFieldCreator](https://base-angewandte.github.io/base-ui-components/#baseformfieldcreator)). |

| attribute             | relevant for                     | default\*                                                                | allowed values                                                 | description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| --------------------- | -------------------------------- | ------------------------------------------------------------------------ | -------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| hidden                | all                              | False                                                                    | True, False                                                    | indicate if this data attribute should be considered for form creation (e.g. true for id)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| field_format          | all                              | full                                                                     | full, half                                                     | specify if the field should fill full width or half in a form<br> (in case it is a 'half' field make sure it has a second 'half' field as well, otherwise the space will be empty)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| field_type            | all                              | text                                                                     | text, autocomplete, chips, chips-below, date, multiline, group | which kind of field should be shown front-end:<br>**text**: simple text field<br> **autocomplete**: text field with autocomplete functionality (source needed!)<br> **chips**: input field with options (optional: dynamic autocomplete) that creates chips out of selected options<br>(if single or multi chips will be determined automatically from field type being an array or object)<br> **chips-below**: same as chips, however chips are not added inline but below the input field<br> **date**: a date field (different formats)<br> **multiline**: a multiline text field<br> **group**: indicates that the fields specified within should be grouped |
| placeholder           | all                              | -                                                                        | string or object                                               | Add a placeholder displayed in the input field<br> A string for all fields except date fields - there it should be an object with 'date' and (if necessary) 'time' attributes that contain the relevant string                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| order                 | all                              | this should be specified for all fields otherwise sorting will be random | number                                                         | this will specify the order in which the fields are displayed in the form                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| source                | chips, chips-below, autocomplete | -                                                                        | a API endpoint                                                 | if the field has a autocomplete functionality (autocomplete field or dynamic chips inputs (`dynamic_autosuggest = true`) or options (`dynamic_autosuggest = false`) this route is **required** to fetch these options<br> (the base url for the API is specified in the front end configuration)                                                                                                                                                                                                                                                                                                                                                                  |
| source\_\*            | chips, chips-below               | -                                                                        | a API endpoint                                                 | as above, to specify additional sources (URLs) for prefetching<br> (e.g. used for form data property `type` --> `source_type`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| set_label_language    | chips                            | False                                                                    | True, False                                                    | specify if the field data have language specific content (e.g. { 'en': 'xxx', 'de': 'yyy' })                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| date_format           | date                             | day                                                                      | day, month, year, date_year                                    | the format of the date field, if day, month or year it will only be possible to enter those, if date_year switch buttons will be displayed to allow switching between day and year format                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| dynamic_autosuggest   | chips                            | False                                                                    | True, False                                                    | define if chips should have a dynamic autocomplete --> this means matching results are live fetched from the API on user input                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| allow_unknown_entries | chips                            | False                                                                    | True, False                                                    | define if only options available in the chips input drop down can be used or user can just enter any string                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| sortable              | chips, chips-below               | False                                                                    | True, False                                                    | should chips be sortable                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| show_label            | group                            | False                                                                    | True, False                                                    | indicates if field groups should have a label                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |

An example can be found in the [BaseForm](https://base-angewandte.github.io/base-ui-components/#baseform) section of the styleguide with "view code".

Also these custom attributes can be extended with functionality needed for the front end - an example how x-attrs are put to use with the standard attributes used above and custom front end (in this case: portfolio) specific attributes (e.g. `prefetch`, `default_role`, `form_group`, …) can be found under [Form customization in Portfolio](https://github.com/base-angewandte/portfolio-backend/blob/master/docs/source/create_forms.md).
