json.set! :data do
  json.array! @<%= plural_table_name %> do |<%= singular_table_name %>|
    json.partial! '<%= plural_table_name %>/<%= singular_table_name %>', <%= singular_table_name %>: <%= singular_table_name %>
    json.url  "
              #{link_to 'Show', <%= singular_table_name %> }
              #{link_to 'Edit', edit_<%= singular_route_name %>_path(<%= singular_table_name %>)}
              #{link_to 'Destroy', <%= singular_table_name %>, method: :delete, data: { confirm: 'Are you sure?' }}
              "
  end
end