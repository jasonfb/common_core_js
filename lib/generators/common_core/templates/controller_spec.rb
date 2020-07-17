require 'rails_helper'


describe <%= controller_class_name %> do
  render_views
  let(:<%= @auth %>) {create(:<%= @auth.gsub('current_', '') %>)}
  let(:<%= singular %>) {create(:<%= singular %>, <%= @auth_identifier %>: <%= @auth %> )}

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:account]
    sign_in :<%= @auth_identifier %>, <%= @auth %> # sign_in(scope, resource)
  end


  describe "index" do
    it "should respond" do
      get :index, xhr: true, format: 'js'
    end
  end

  describe "new" do
    it "should show form" do
      get :new, xhr: true, format: 'js'
    end
  end

  describe "create" do
    it "should create a new crusade" do
      expect {
        post :create, xhr: true, format: 'js', params: {
            <%= singular %>: {
            name: "Abc crusade",
        }}
      }.to change { <%= @singular_class %>.all.count }.by(1)
      assert_response :ok
    end

    # it "should not update if there are errors" do
    #   post :create, xhr: true, format: 'js',  params: {id: <%= singular %>.id,
    #                                                    <%= singular %>: {skin_id: nil}}
    #
    #   expect(controller).to set_flash.now[:alert].to(/Oops, your <%= singular %> could not be saved/)
    # end
  end

  describe "edit" do
    it "should show the object as editable" do
      get :edit, xhr: true, format: 'js',  params: {id: <%= singular %>.id}
      assert_response :ok
    end


    it "should show form has html" do
      get :edit, xhr: true,  format: 'js',  params: {id: <%= singular %>.id}
      assert_response :ok

    end
  end

  describe "update" do

    it "should update" do
      put :update, xhr: true, format: 'js',
          params: {
            id: <%= singular %>.id,
            <%= singular %>: {
                <%= columns_spec_with_sample_data %>
            }}

      assert_response :ok
    end

    # it "should not update if invalid" do
    #   put :update, xhr: true, format: 'js',
    #       params: {
    #         id: <%= singular %>.id,
    #         <%= singular %>: {
    #           <%= columns_spec_with_sample_data %>
    #       }}
    #
    #   assert_response :ok
    #
    #   expect(controller).to set_flash.now[:alert].to(/Oops, your <%= singular %> could not be saved/)
    # end
  end

  describe "#destroy" do
    it "should destroy" do
      post :destroy, format: 'js', params: { id: <%= singular %>.id }
      assert_response :ok
      expect(<%= @singular_class %>.count).to be(0)
    end
  end

end

