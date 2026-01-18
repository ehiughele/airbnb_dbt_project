{% macro learn_variables() %}
    -- Jinja Variable
    {% set your_name_jinja = "Ehibhahiemenughele" %}
    {{ log("Hello " ~ your_name_jinja, info=True) }}

    -- DBT Variable Note: ypu concatenate strings in dbt using '~' operator
    {{ log("Hello dbt user " ~ var('user_name', "No USERNAME IS SET!!"), info=True) }}
{% endmacro %}