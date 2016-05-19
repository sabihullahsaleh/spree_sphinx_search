ThinkingSphinx::Index.define('spree/howmuch_shop', with: :active_record, delta: ThinkingSphinx::Deltas::SidekiqDelta) do
    
    is_active_sql = "(#{Spree::HowmuchShop.table_name}.deleted_at IS NULL AND #{Spree::HowmuchShop.table_name}.is_authentic = 't'"
    indexes :name, sortable: true
    indexes :address
    indexes :description
    
    has longitude, latitude
    
    has products.id, as: :product_ids, facet: true  
    has variants.id, as: :variant_ids, facet: true  
  
    has :is_authentic, type: :boolean
    has is_active_sql, as: :is_active, type: :boolean
  end