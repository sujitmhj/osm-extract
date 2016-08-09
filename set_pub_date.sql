update base_resourcebase set date = current_date where id in (select resourcebase_ptr_id from layers_layer where store = 'osm_extracts');
