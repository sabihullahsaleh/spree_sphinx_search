ThinkingSphinx::Index.define 'spree/product', with: :active_record do
    #is_active_sql = "(spree_products.deleted_at IS NULL AND spree_products.available_on <= NOW() #{'AND (spree_products.count_on_hand > 0)' unless Spree::Config[:allow_backorders]} )"
    is_active_sql = "(spree_products.deleted_at IS NULL AND spree_products.available_on <= NOW())"   
    option_sql = lambda do |option_name|
      sql = <<-eos
        SELECT DISTINCT p.id, ov.id
        FROM #{Spree::OptionValue.table_name} AS ov
        LEFT JOIN #{Spree::OptionType.table_name} AS ot ON (ov.option_type_id = ot.id)
        LEFT JOIN spree_option_values_variants AS ovv ON (ovv.option_value_id = ov.id)
        LEFT JOIN #{Spree::Variant.table_name} AS v ON (ovv.variant_id = v.id)
        LEFT JOIN #{Spree::Product.table_name} AS p ON (v.product_id = p.id)
        WHERE (ot.name = '#{option_name}' AND p.id>=$start AND p.id<=$end);
        #{source.to_sql_query_range}
      eos
      sql.gsub("\n", ' ').gsub('  ', '')
    end

    property_sql = lambda do |property_name|
      sql = <<-eos
          (SELECT spp.value
          FROM #{Spree::ProductProperty.table_name} AS spp
          INNER JOIN #{Spree::Property.table_name} AS sp ON sp.id = spp.property_id
          WHERE sp.name = '#{property_name}' AND spp.product_id = #{Spree::Product.table_name}.id)
      eos
      sql.gsub("\n", ' ').gsub('  ', '')
    end
    
    indexes :name, sortable: true
    indexes master.sku
    indexes variants.sku, as: :variant_skus
    indexes :description
    #indexes :meta_description
    #indexes :meta_keywords

    indexes taxons.name, as: :taxon_name, facets: true
    indexes brand_taxons.name, as: :brand_name, facets: true
        
    has taxons.id, as: :taxon_ids, facet: true  
    has brand_taxons.id, as: :brand_ids, facet: true  
    has category_taxons.id, as: :category_ids, facet: true  
      
    join variant_images
    has "COUNT(#{Spree::Image.table_name}.id) > 0", as: :has_images, type: :boolean  
    #has properties.name
  #  has variant.price , as: :price
#  has variant.original_price , as: :original_price
    
    #TODO when searching for price range inside shop, we need to get price of product within the shop 
#    has master.default_price.amount, type: :float, as: :master_price
    has shop_variant_prices.price, type: :float, as: :shop_prices
    has shop_variant_prices.howmuch_shop_id, as: :shop_ids, facet: true
    #group_by "spree_prices.amount"
#    group_by :available_on
    #group_by "#{Spree::ProductProperty.table_name}.name"
    has is_active_sql, :as => :is_active, :type => :boolean

    #has "CRC32(#{property_sql.call('Brand')}", as: :brand, type: :integer, facets: true
    
    source.model.indexed_attributes.each do |attr|
      has attr[:field], attr[:options]
    end
    source.model.indexed_properties.each do |prop|
      has property_sql.call(prop[:name].to_s), :as => :"#{prop[:name]}_property", :type => prop[:type]
    end
    source.model.indexed_options.each do |opt|
      has option_sql.call(opt.to_s), :as => :"#{opt}_option", :source => :ranged_query, :type => :multi, :facet => true
    end
  end