{% macro get_powers_of_two(upper_bound) %}

    {% if upper_bound <= 0 %}
    {{ exceptions.raise_compiler_error("upper bound must be positive") }}
    {% endif %}

    {% for _ in range(1, 100) %}
       {% if upper_bound <= 2 ** loop.index %}{{ return(loop.index) }}{% endif %}
    {% endfor %}

{% endmacro %}


{% macro generate_series(upper_bound) %}

    {% set n = dbt_utils.get_powers_of_two(upper_bound) %}

    with

    {% for i in range(n) %}

    p{{i}} as (
        select 0 as generated_number union all select 1
    ) {% if not loop.last %},{% endif %}

    {% endfor %}

    , unioned as (

    select

    {% for i in range(n) %}
    p{{i}}.generated_number * pow(2, {{i}})
    {% if not loop.last %} + {% endif %}
    {% endfor %}
    + 1
    as generated_number

    from

    {% for i in range(n) %}
    p{{i}}
    {% if not loop.last %} cross join {% endif %}
    {% endfor %}

    )

    select *
    from unioned
    where generated_number <= {{upper_bound}}
    order by generated_number

{% endmacro %}
