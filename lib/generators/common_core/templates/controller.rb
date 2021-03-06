class <%= controller_class_name %> < <%= controller_descends_from %>
<% unless @auth_identifier == '' || @auth.nil? %>before_action :authenticate_<%= auth_identifier %>!<% end %>
<% if any_nested? %> <% @nested_args.each do |arg| %>
  before_action :load_<%= arg %><% end %> <% end %>
  before_action :load_<%= singular_name %>, only: [:show, :edit, :update, :destroy]
  helper :common_core
  include CommonCoreJs::ControllerHelpers
  <% if any_nested? %><% nest_chain = [] %> <% @nested_args.each { |arg|
    this_scope =   nest_chain.empty? ?  "#{@auth ? auth_object : class_name}.#{arg}s" : "@#{nest_chain.last}.#{arg}s"
      nest_chain << arg %>def load_<%= arg %>
    @<%= arg %> = <%= this_scope %>.find(params[:<%= arg %>_id])
  end<% } %><% end %>

<% if !@self_auth %>
  def load_<%= singular_name %>
    @<%= singular_name %> = <%= object_scope %>.find(params[:id])
  end
  <% else %>
  def load_<%= singular_name %>
    @<%= singular_name %> = <%= auth_object %>
  end<% end %>

  def index
<% if !@self_auth %>
    @<%= plural_name %> = <%= object_scope %><% if model_has_strings? %>.where(<%=class_name %>.arel_table[:email].matches("%#{@__general_string}%"))<% end %>.page(params[:page])
    <% else %>
    @<%= plural_name %> = [<%= auth_object %>]
    <% end %>
    respond_to do |format|
      format.js<% if @with_index %>
      format.html {render 'all.haml'}<% end %>
    end
  end

<% if create_action %>  def new <% if !@auth.nil? %>
    @<%= singular_name %> = <%= class_name  %>.new(<%= @object_owner_sym %>: <%= @object_owner_eval %>)
   <% else %>
    @<%= singular_name %> = <%= class_name  %>.new
   <% end %>
    respond_to do |format|
      format.js
    end
  end

  def create
    modified_params = modify_date_inputs_on_params(<%=singular_name %>_params.dup<% if !@object_owner_sym.empty? %>.merge!(<%= @object_owner_sym %>: <%= @object_owner_eval %> )<% end %> <%= @auth ? ', ' + @auth : '' %>)
    @<%=singular_name %> = <%=class_name %>.create(modified_params)
    respond_to do |format|
      if @<%= singular_name %>.save
      else
        flash[:alert] = "Oops, your <%=singular_name %> could not be created."
      end
      format.js
    end
  end<% end %>

  def show
    respond_to do |format|
      format.html
    end
  end

  def edit
    respond_to do |format|
      format.js
    end
  end

  def update
    respond_to do |format|
      if !@<%=singular_name %>.update(modify_date_inputs_on_params(<%= singular %>_params<%= @auth ? ', ' + @auth : '' %>))
        flash[:alert] = "<%=singular_name.titlecase %> could not be saved"
      end
      format.js {}
    end
  end

<% if destroy_action %>def destroy
    respond_to do |format|
      begin
        @<%=singular_name%>.destroy
      rescue StandardError => e
        flash[:alert] = "<%=singular_name.titlecase %> could not be deleted"
      end
      format.js {}
    end
  end<% end %>

  def <%=singular_name%>_params
    params.require(:<%=singular_name%>).permit( <%= @columns %> )
  end

  def default_colspan
    <%= @default_colspan %>
  end

  def namespace
    <% if @namespace %>
      "<%= @namespace %>/"
    <% else %>
      ""
    <% end %>
  end


  def common_scope
    @nested_args
  end

end


