update base_resourcebase set date = current_timestamp where id in (select resourcebase_ptr_id from layers_layer where store = 'nepal_osm');
