class <%= controller_class_name %> < <%= controller_descends_from %>
<% unless @auth_identifier.nil? %>
  before_action :authenticate_<%= auth_identifier %>!

<% end %>
<% if any_nested? %> <% @nested_args.each do |arg| %>
  before_action :load_<%= arg %><% end %> <% end %>
  before_action :load_<%= singular_name %>, only: [:show, :edit, :update, :destroy]
  helper :common_core

  <% if any_nested? %><% nest_chain = [] %> <% @nested_args.each do |arg| %>
      <% if nest_chain.empty?
        this_scope = "#{@auth ? auth_object : class_name}.#{arg}s"
      else
        this_scope = "@#{nest_chain.last}.#{arg}s"
      end
      nest_chain << arg %>
  def load_<%= arg %>
    @<%= arg %> = <%= this_scope %>.find(params[:<%= arg %>_id])
  end<% end %> <% end %>

  def load_<%= singular_name %>
    @<%= singular_name %> = <%= object_scope %>.find(params[:id])
  end

  def index
    @<%= plural_name %> = <%= object_scope %><% if model_has_strings? %>.where(<%=class_name %>.arel_table[:email].matches("%#{@__general_string}%"))<% end %>.page(params[:page])

    respond_to do |format|
      format.js<% if @with_index %>
      format.html {render 'all.haml'}<% end %>
    end
  end

  def new
    @<%= singular_name %> = <%= class_name  %>.new(<%= create_merge_params %>)
    respond_to do |format|
      format.js
    end
  end

  def create
    modified_params = modify_date_inputs_on_params(<%=singular_name %>_params.dup<% if !create_merge_params.empty? %>.merge!(<%= create_merge_params %>)<%end%> , <%= @auth ? @auth : "nil" %>)
    @<%=singular_name %> = <%=class_name %>.create(modified_params)
    respond_to do |format|
      if @<%= singular_name %>.save
      else
        flash[:alert] = "Oops, your <%=singular_name %> could not be saved."
      end
      format.js
    end
  end

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
      if !@<%=singular_name %>.update(modify_date_inputs_on_params(<%= singular %>_params ))
        flash[:alert] = "<%=singular_name.titlecase %> could not be saved"
      end
      format.js {}
    end
  end

  def destroy
    respond_to do |format|
      begin
        @<%=singular_name%>.destroy
      rescue StandardError => e
        flash[:alert] = "<%=singular_name.titlecase %> could not be deleted"
      end
      format.js {}
    end
  end

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


