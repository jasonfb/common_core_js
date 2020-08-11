require 'rails/generators/erb/scaffold/scaffold_generator'
require 'ffaker'



module CommonCore

  module GeneratorHelper
    def text_area_output(col, field_length)
      lines = field_length % 40
      if lines > 5
        lines = 5
      end

      ".row
  %div{class: \"form-group col-md-4 \#{'alert-danger' if #{singular}.errors.details.keys.include?(:#{col.to_s})}\"}
    = f.text_area :#{col.to_s}, class: 'form-control', cols: 40, rows: '#{lines}'
    %label.form-text
      #{col.to_s.humanize}\n"
    end



    def field_output(col, type = nil, width)
      ".row
  %div{class: \"form-group col-md-4 \#{'alert-danger' if #{singular}.errors.details.keys.include?(:#{col.to_s})}\"}
    = f.text_field :#{col.to_s}, value: @#{singular}.#{col.to_s}, size: #{width}, class: 'form-control', type: '#{type}'
    %label.form-text
      #{col.to_s.humanize}\n"
    end
  end


  class ScaffoldGenerator < Erb::Generators::ScaffoldGenerator
    hook_for :form_builder, :as => :scaffold

    source_root File.expand_path('templates', __dir__)
    attr_accessor :path, :singular, :plural, :singular_class, :nest_with


    include GeneratorHelper


    def initialize(*meta_args) #:nodoc:
      super

      begin
        object = eval(class_name)
      rescue StandardError => e
        puts "Ooops... it looks like there is no object for #{class_name}. Please define the object + database table first."
        exit
      end



      args = meta_args[0]
      @singular = args[0].tableize.singularize # should be in form hello_world


      @plural = @singular + "s" # supply to override; leave blank to use default
      @singular_class = @singular.titleize.gsub(" ", "")
      @nest = nil
      @namespace = nil
      @nested_args = []

      @auth = "current_user"
      @auth_identifier = nil

      args[1..-1].each do |a|
        var_name, var_value = a.split("=")
        case (var_name)

        when "plural"
          @plural = var_value
        when "nest"
          @nest = var_value
        when "namespace"
          @namespace = var_value
        when "auth"
          @auth = var_value
        when "auth_identifier"
          @auth_identifier = var_value || ""
        end
      end



      auth_assoc = @auth.gsub("current_","")
      auth_assoc_field = auth_assoc + "_id"



      exclude_fields = [auth_assoc_field.to_sym, :id, :created_at, :updated_at, :encrypted_password, :reset_password_token,
                        :reset_password_sent_at, :remember_created_at, :confirmation_token, :confirmed_at,
                        :confirmation_sent_at, :unconfirmed_email]
      begin
        @columns = object.columns.map(&:name).map(&:to_sym).reject{|field| exclude_fields.include?(field) }
      rescue StandardError => e
        puts "Ooops... it looks like is an object for #{class_name}. Please create the database table with fields first. "
        exit
      end

      flags = meta_args[1]
      flags.each do |f|
        case (f)
        when "--god"
          @auth = nil
        when "--with-index"
          @with_index = true
        when "--specs-only"
          @specs_only = true
        when "--no-specs"
          @no_specs = true
        end
      end

      if @specs_only && @no_specs
        puts "oops… you seem to have specified both the --specs-only flag and --no-specs flags. this doesn't make any sense, so I am aborting. sorry."
        exit
      end

      if @auth_identifier.nil? && !@auth.nil?
        @auth_identifier = @auth.gsub("current_", "")
      end



      if @auth && auth_identifier == @singular
        @self_auth = true
      end

      if !@nest.nil?
        @nested_args = @nest.split("/")

        @nested_args_plural = {}
        @nested_args.each do |a|
          @nested_args_plural[a] = a + "s"
        end
      end
    end

    def formats
      [format]
    end

    def format
      nil
    end

    def copy_controller_and_spec_files
      @default_colspan = @columns.size

      unless @specs_only
        template "controller.rb", File.join("app/controllers#{namespace_with_dash}", "#{plural}_controller.rb")
        if @namespace &&  defined?(controller_descends_from) == nil
          template "base_controller.rb", File.join("app/controllers#{namespace_with_dash}", "base_controller.rb")
        end
      end

      unless @no_specs
        template "controller_spec.rb", File.join("spec/controllers#{namespace_with_dash}", "#{plural}_controller_spec.rb")
      end

      template "_errors.haml", File.join("app/views#{namespace_with_dash}", "_errors.haml")
    end

    def list_column_headings
      @columns.map(&:to_s).map{|col_name| '      %th{:scope => "col"} ' + col_name.humanize}.join("\r")
    end

    def columns_spec_with_sample_data
      @columns.map { |c|
        if eval("#{singular_class}.columns_hash['#{c}']").nil?
          byebug
        end
        type = eval("#{singular_class}.columns_hash['#{c}']").type
        random_data = case type
          when :integer
            rand(1...1000)
          when :string
            FFaker::AnimalUS.common_name
          when :text
            FFaker::AnimalUS.common_name
          when :datetime
            Time.now + rand(1..5).days
        end
        c.to_s + ": '" + random_data.to_s + "'"
      }.join(", ")
    end

    def object_parent_mapping_as_argument_for_specs
      if @nested_args.any?
        ", " + @nested_args.last + ": " + @nested_args.last
      elsif @auth
       ", #{@auth_identifier}: #{@auth}"
      end
    end

    def objest_nest_factory_setup
      res = ""
      if @auth
        last_parent = ", #{@auth_identifier}: #{@auth}"
      end

      @nested_args.each do |arg|
        res << "  let(:#{arg}) {create(:#{arg} #{last_parent} )}\n"
        last_parent = ", #{arg}: #{arg}"
      end
      res
    end


    def objest_nest_params_by_id_for_specs
      @nested_args.map{|arg|
        "#{arg}_id: #{arg}.id"
      }.join(",\n          ")
    end


    def controller_class_name
      res = ""
      res << @namespace.titleize + "::" if @namespace
      res << plural.titleize.gsub(" ", "") + "Controller"
      res
    end

    def singular_name
      @singular
    end

    def plural_name
      plural
    end

    def auth_identifier
      @auth_identifier
    end


    def path_helper_singular
      "#{@namespace+"_" if @namespace}#{(@nested_args.join("_") + "_" if @nested_args.any?)}#{singular}_path"
    end

    def path_helper_plural
      "#{@namespace+"_" if @namespace}#{(@nested_args.join("_") + "_" if @nested_args.any?)}#{plural}_path"
    end

    def path_arity
      res = ""
      if @nested_args.any?
        res << nested_objects_arity + ", "
      end
      res << "@" + singular
    end

    def line_path_partial
      "#{@namespace+"/" if @namespace}#{plural}/line"
    end

    def nested_assignments
      @nested_args.map{|a| "#{a}: @#{a}"}.join(", ") #metaprgramming into Ruby hash
    end

    def nested_objects_arity
      @nested_args.map{|a| "@#{a}"}.join(", ")
    end

    def nested_arity_for_path
      @nested_args.join(", ") #metaprgramming into arity for the Rails path helper
    end

    def object_scope
      if @auth
        if @nested_args.none?
          @auth + ".#{plural}"
        else
          "@" + @nested_args.last + ".#{plural}"
        end
      else
        @singular_class
      end
    end


    def all_objects_root
      if @auth
        if @self_auth
          @singular_class + ".where(id: #{@auth}.id)"
        elsif @nested_args.none?
          @auth + ".#{plural}"
        else
          "@" + @nested_args.last + ".#{plural}"
        end
      else
        @singular_class + ".all"
      end
    end

    def any_nested?
      @nested_args.any?
    end

    def all_objects_variable

      # needs the authenticated root user
      # "#{@auth}.#{ @nested_args.map{|a| "#{@nested_args_plural[a]}.find(@#{a})"}.join('.') + "." if @nested_args.any?}#{plural}"

      all_objects_root + ".page(params[:page])"

    end

    def auth_object
      @auth
    end

    def copy_view_files
      return if @specs_only
      js_views.each do |view|
        formats.each do |format|
          filename = cc_filename_with_extensions(view, ["js","erb"])
          template filename, File.join("app/views#{namespace_with_dash}", controller_file_path, filename)
        end
      end


      haml_views.each do |view|
        formats.each do |format|
          filename = cc_filename_with_extensions(view, "haml")
          template filename, File.join("app/views#{namespace_with_dash}", controller_file_path, filename)
        end
      end
    end

    def namespace_with_dash
      if @namespace
        "/#{@namespace}"
      else
        ""
      end
    end

    def namespace_with_trailing_dash
      if @namespace
        "#{@namespace}/"
      else
        ""
      end
    end

    def js_views
      %w(index create destroy edit new update)
    end

    def haml_views
      res =  %w(_edit _form _line _list _new)
      if @with_index
        res << 'all'
      end
      res
    end


    def handler
      :erb
    end


    def create_merge_params
      if @auth && ! @self_auth
        "#{@auth_identifier}: #{@auth}"
      else
        ""
      end
    end

    def model_has_strings?
      false
    end


    def model_search_fields # an array of fields we can search on
      []
    end

    def all_form_fields
      res = @columns.map { |col|


        type = eval("#{singular_class}.columns_hash['#{col}']").type
        limit = eval("#{singular_class}.columns_hash['#{col}']").limit
        sql_type = eval("#{singular_class}.columns_hash['#{col}']").sql_type

        case type
        when :integer
          # look for a belongs_to on this object
          if col.to_s.ends_with?("_id")
            # guess the association name label


            assoc_name = col.to_s.gsub("_id","")
            assoc = eval("#{singular_class}.reflect_on_association(:#{assoc_name})")
            if assoc.nil?
              puts "*** Oops. on the #{singular_class} object, there doesn't seem to be an association called '#{assoc_name}'"
              exit
            end

            if assoc.active_record.column_names.include?("name")
              display_column = "name"
            elsif assoc.active_record.column_names.include?("to_label")
              display_column = "to_label"
            elsif assoc.active_record.column_names.include?("full_name")
              display_column = "full_name"
            elsif assoc.active_record.column_names.include?("display_name")
              display_column = "display_name"
            elsif assoc.active_record.column_names.include?("email")
              display_column = "email"
            else
              puts "Can't find a display_column on {singular_class} object"
            end

            ".row
  %div{class: \"form-group col-md-4 \#{'alert-danger' if #{singular}.errors.details.keys.include?(:#{assoc_name.to_s})}\"}
    = f.collection_select(:#{col.to_s}, #{assoc_name.titleize}.all, :id, :#{display_column}, {prompt: true, selected: @#{singular}.#{col.to_s} }, class: 'form-control')
    %label.small.form-text.text-muted
      #{col.to_s.humanize}"

          else
            ".row
  %div{class: \"form-group col-md-4 \#{'alert-danger' if #{singular}.errors.details.keys.include?(:#{col.to_s})}\"}
    = f.text_field :#{col.to_s}, value: @#{singular}.#{col.to_s}, class: 'form-control', size: 4, type: 'number'
    %label.form-text
      #{col.to_s.humanize}\n"
          end
        when :string
          limit ||= 256
          if limit <= 256
            field_output(col, nil, limit)
          else
            text_area_output(col, limit)
          end

        when :text
          limit ||= 256
          if limit <= 256
            field_output(col, nil, limit)
          else
            text_area_output(col, limit)
          end

        when :datetime
          ".row
  %div{class: \"form-group col-md-4 \#{'alert-danger' if #{singular}.errors.details.keys.include?(:#{col.to_s})}\"}
    = datetime_field_localized(f, :#{col.to_s}, @#{singular}.#{col.to_s}, '#{col.to_s.humanize}', #{@auth ? @auth+'.timezone' : 'nil'})"
        when :date
        ".row
  %div{class: \"form-group col-md-4 \#{'alert-danger' if #{singular}.errors.details.keys.include?(:#{col.to_s})}\"}
    = date_field_localized(f, :#{col.to_s}, @#{singular}.#{col.to_s}, '#{col.to_s.humanize}', #{@auth ? @auth+'.timezone' : 'nil'})"
        when :time
          ".row
  %div{class: \"form-group col-md-4 \#{'alert-danger' if #{singular}.errors.details.keys.include?(:#{col.to_s})}\"}
    = time_field_localized(f, :#{col.to_s}, @#{singular}.#{col.to_s}, '#{col.to_s.humanize}', #{@auth ? @auth+'.timezone' : 'nil'})"

      end

    }.join("\n")
      return res
    end


    def all_line_fields
      res = "%tr{'data-id': #{singular}.id, 'data-edit': 'false'}\n"

      res << @columns.map { |col|
        type = eval("#{singular_class}.columns_hash['#{col}']").type
        limit = eval("#{singular_class}.columns_hash['#{col}']").limit
        sql_type = eval("#{singular_class}.columns_hash['#{col}']").sql_type

        case type
        when :integer
          # look for a belongs_to on this object
          if col.to_s.ends_with?("_id")

            assoc_name = col.to_s.gsub("_id","")


            assoc = eval("#{singular_class}.reflect_on_association(:#{assoc_name})")

            if assoc.nil?
              puts "*** Oops. on the #{singular_class} object, there doesn't seem to be an association called '#{assoc_name}'"
              exit
            end

            if assoc.active_record.column_names.include?("name")
              display_column = "name"
            elsif assoc.active_record.column_names.include?("to_label")
              display_column = "to_label"
            elsif assoc.active_record.column_names.include?("full_name")
              display_column = "full_name"
            elsif assoc.active_record.column_names.include?("display_name")
              display_column = "display_name"
            elsif assoc.active_record.column_names.include?("email")
              display_column = "email"
            else
              puts "cant find any column to use as label for #{assoc.name.to_s}; any of name, to_labe, full_name, display_name, or email"
            end

            "  %td
    = #{singular}.#{assoc.name.to_s}.#{display_column}"

          else
            "  %td
    = #{singular}.#{col}"
          end
        when :string
          width = (limit && limit < 40) ? limit : (40)
          "  %td
    = #{singular}.#{col}"
        when :text
          "  %td
    = #{singular}.#{col}"
        when :datetime
          "  %td
    - unless #{singular}.#{col}.nil?
      = #{singular}.#{col}.in_time_zone(current_timezone).strftime('%m/%d/%Y @ %l:%M %p ') + timezonize(current_timezone)
    - else
      %span.alert-danger
        MISSING
"
        when :date
          "  %td
    - unless #{singular}.#{col}.nil?
      = #{singular}.#{col}
    - else
      %span.alert-danger
        MISSING
"
        when :time
          "  %td
    - unless #{singular}.#{col}.nil?
      = #{singular}.#{col}.in_time_zone(current_timezone).strftime('%l:%M %p ') + timezonize(current_timezone)
    - else
      %span.alert-danger
        MISSING
"

        end
      }.join("\n")
      return res
    end


    def controller_descends_from
      if defined?(@namespace.titlecase + "::BaseController")
        @namespace.titlecase + "::BaseController"
      else
        "ApplicationController"
      end
    end


    def destroy_action
      return false if @self_auth
      return true
    end

    def create_action
      return false if @self_auth
      return true
    end


    private # thor does something fancy like sending the class all of its own methods during some strange run sequence
    # does not like public methods

    def cc_filename_with_extensions(name, file_format = format)
      [name, file_format].compact.join(".")
    end
  end

end



