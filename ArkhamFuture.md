# Arkham Future #

<p>
I'm using this document to flesh out my ideas about a future refactoring of <a href='Arkham.md'>Arkham</a>. Any code changes will be taking place in the <a href='http://code.google.com/p/noidman/source/browse/#svn/branches/arkham-future'>'future' branch</a>. </p>

## Summary ##

<p>
The ARK service allows ARKs -- managed, persistent, and globally unique identifiers -- to be created for URLs. Each ARK may also have a statement of persistence support ("contract") and a metadata record attached, but are optional. Though the service is being designed primarily for our use at the Princeton University Library, there is interest in such an application outside of Princeton. Thus the app should support multiple name assigning authorities. The application will also make use of role-based authorization, though I am not yet sure how I will handle the authz or authn. The app should be fully compliant with the <a href='http://www.cdlib.org/inside/diglib/ark/arkspec.pdf'>ARK specification (PDF)</a> upon completion. </p>
<p>
Arkham Future is being developed here:<br>
</p>
```
svn checkout http://noidman.googlecode.com/svn/branches/arkham-future/ arkham-read-only  
```
<p>
In the meantime, you may browse the <a href='http://code.google.com/p/noidman/source/browse/#svn/branches/arkham-future'>source code</a> as it develops.<br>
</p>

## General ##

  * The app should be a stand-alone web application as well as a web service. App should make use of Rails web service hooks and generate WADL (or WSDL) description of API for clients.
  * Roles will be used for authZ. Use HTTP authentication in a before\_filter for controllers/actions requiring authN?

### Generalized schema ###

See the bulleted list below or a graphical representation (under work)

  * Service has many authorities
    * Authority has many roles (see below)
    * Authority has many minters
      * Minter has many identifiers (see below)
      * Minter has many roles (see below)
      * Minter MAY HAVE one default contract
    * Authority has many contracts
      * Contract has many identifiers (see below)
    * Authority MAY HAVE one default contract
  * Service has many roles
    * Role has many users
      * User has many roles
      * User has many identifiers
        * Identifiers should be unique within the minter and within the containing authority

## Model ##

### Naive domain model ###

```
class Identifier < ActiveRecord::Base
  belongs_to :users
  belongs_to :minters
  belongs_to :contracts
  validates_presence_of :ark, :url, :minter_id, :user_id
  validates_uniqueness_of :ark, :url, :scope => [:minter_id]
end
```
```
class User < ActiveRecord::Base
  has_and_belongs_to_many :roles
  has_many :identifiers
  validates_presence_of :name
end
```
```
class Role < ActiveRecord::Base
  has_and_belongs_to_many :users
  belongs_to :authorities
  belongs_to :minters
  validates_presence_of :name
end
```
```
class Contract < ActiveRecord::Base
  has_many :identifiers
  validates_presence_of :statement
end
```
```
class Minter < ActiveRecord::Base
  has_many :identifiers
  belongs_to :authorities
  def mint
    ArkUtils.mint!( self )
  end
end
```
```
class Authority < ActiveRecord::Base
  has_many :minters
  validates_presence_of :number, :random
  validates_uniqueness_of :number
  validates_numericality_of :number
end
```

### Utility classes ###

```
class ArkUtils
  # mint a unique ARK within the given minter (and authority)
  # make sure to check the value of minter.random and minter.prefix

  XDIGITS = %w( 0 1 2 3 4 5 6 7 8 9 b c d f g h j k m n p q r s t v w x z )
  DIGITS = %w( 0 1 2 3 4 5 6 7 8 9 )

  class << self
    def mint( authority )
      # mint a unique ARK within the given authority
      # random template: eeddeeddk
      #   e is an xdigit: 0123456789bcdfghjkmnpqrstvwxz
      #   d is a digit:   0123456789
      #   k is checkchar: special xdigit
 
      # first generate a name based on default 'eeddeedd(k)' template
      name = '' << XDIGITS[rand(XDIGITS.length)] << XDIGITS[rand(XDIGITS.length)] <<
             DIGITS[rand(DIGITS.length)] << DIGITS[rand(DIGITS.length)] <<
             XDIGITS[rand(XDIGITS.length)] << XDIGITS[rand(XDIGITS.length)] <<
             DIGITS[rand(DIGITS.length)] << DIGITS[rand(DIGITS.length)]

      # then prepend authority.number and the '/' character e.g., "11111/id"
      ark = authority.number.to_s << '/' << name 

      # then generate a check character
      identifier = name << generate_check( ark )      

      # return identifier w/ check char to caller
      identifier
    end

    def generate_check( ark )
      sum = 0
      position = 0
      ark.split( '' ).each do |char|
        position = position + 1
        if char == '/'
          ordinal = 0
        else
          ordinal = XDIGITS.index( char )
        end
        sum = ordinal * position + sum
      end
      XDIGITS[sum % XDIGITS.length]
    end

    def validate( ark )
      generate_check( ark[0...-1] ) == ark[-1].chr 
    end

    private :generate_check
  end
end 
```
<h3>Migrations based on naive domain model</h3>
<p>
Basic migrations are generated by scaffold_resource generators above.  Just add in :default and :null values where appropriate.<br>
</p>
```
class CreateIdentifiers < ActiveRecord::Migration
  def self.up
    create_table :identifiers do |t|
      t.column :ark, :string, :null => false
      t.column :url, :string, :null => false
      t.column :comment, :text
      t.column :metadata, :text
      t.column :minter_id, :integer, :null => false
      t.column :contract_id, :integer
      t.column :user_id, :integer, :null => false
      t.column :created_on, :datetime
      t.column :updated_on, :datetime
    end
  end

  def self.down
    drop_table :identifiers
  end
end
```
```
class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column :name, :string, :null => false
      t.column :password, :string
      t.column :email, :string
    end
  end

  def self.down
    drop_table :users
  end
end
```
```
class CreateUsersRoles < ActiveRecord::Migration
  def self.up
    create_table :users_roles do |t|
      t.column :user_id, :integer, :null => false
      t.column :role_id, :integer, :null => false
    end
  end

  def self.down
    drop_table :users_roles
  end
end
```
```
class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.column :name, :string, :null => false
      t.column :label, :text
      t.column :authority_id, :integer, :null => false
      t.column :minter_id, :integer, :null => false
    end
  end

  def self.down
    drop_table :roles
  end
end
```
```
class CreateContracts < ActiveRecord::Migration
  def self.up
    create_table :contracts do |t|
      t.column :statement, :text, :null => false
      t.column :label, :string
    end
  end

  def self.down
    drop_table :contracts
  end
end
```
```
class CreateMinters < ActiveRecord::Migration
  def self.up
    create_table :minters do |t| 
      t.column :label, :string
      t.column :random, :boolean, :null => false, :default => false
      t.column :prefix, :string
      t.column :authority_id, :integer, :null => false
    end
  end

  def self.down
    drop_table :minters
  end
end
```
```
class CreateAuthorities < ActiveRecord::Migration
  def self.up
    create_table :authorities do |t| 
      t.column :number, :integer, :null => false
      t.column :label, :string
    end
  end

  def self.down
    drop_table :authorities
  end
end
```
```
class CreateIndexes < ActiveRecord::Migration
  def self.up
    add_index :identifiers, :ark
    add_index :identifiers, :url
    add_index :identifiers, :comment
    add_index :identifiers, :metadata
    add_index :users, :name
    add_index :roles, :name
    add_index :contracts, :statement
    add_index :authorities, :number
  end

  def self.down
    remove_index :identifiers, :ark
    remove_index :identifiers, :url
    remove_index :identifiers, :comment
    remove_index :identifiers, :metadata
    remove_index :users, :name
    remove_index :roles, :name
    remove_index :contracts, :statement
    remove_index :authorities, :number
  end
end
```
<h3>Initial data creation</h3>
```
class AddRoles < ActiveRecord::Migration
  def self.up
    @role = Role.create :name => 'admin',
      :label => 'Administrator role - godly abilities'
  end

  def self.down
    Role.delete @role
  end
end
```
```
class AddUsers < ActiveRecord::Migration
  def self.up
    @user = User.create :name => 'Michael J. Giarlo',
      :password =>  'This is not a real password.',
      :email => 'mgiarlo@princeton.edu'
  end

  def self.down
    User.delete @user
  end
end
```
```
class AddUsersRoles < ActiveRecord::Migration
  def self.up
    # assuming user_id and role_id are 1 for now
    execute "INSERT INTO users_roles (user_id, role_id) VALUES (1, 1)"
  end

  def self.down
    execute "DELETE FROM users_roles WHERE user_id = 1 AND role_id = 1"
  end
end
```
```
class AddContracts < ActiveRecord::Migration
  def self.up
    @contract = Contract.create :statement => 'We agree to maintain this persistent identifier in perpetuity in accordance with yada yada yada',
      :label =>  'Persistence in perpetuity',
  end

  def self.down
    Contract.delete @contract
  end
end
```
```
class AddAuthorities < ActiveRecord::Migration
  def self.up
    @authority = Authority.create :number => 83030,
      :label =>  'Princeton University Library',
  end

  def self.down
    Authority.delete @authority
  end
end
```
```
class AddMinters < ActiveRecord::Migration
  def self.up
    # assuming authority_id is 1 for now
    @minter = Minter.create :label => 'Sequential EADs',
      :random => false,
      :authority_id => 1,
      :prefix => 'ead'
  end
  def self.down
    Minter.delete @minter
  end
end
```
```
class AddIdentifiers < ActiveRecord::Migration
  def self.up
    # assuming authority_id and user_id are 1 for now
    authority = Authority.find( :number => 83030 )
    minter = Minter.find(authority, :prefix == 'ead' )
    @identifier = Identifier.create :ark => minter.mint!,
      :url =>  'http://diglib.princeton.edu/',
      :authority_id => authority,    
      :user_id => 1
  end

  def self.down
    Identifier.delete @identifier
  end
end
```

### Model: Methods and other notes ###

  * It might be nice to have the ability to create multiple authorities
  * Model will include all validation methods
  * Model will include methods for minting and binding across minters
  * Should support variants ('.') and hierarchy ('/') as described in ARK spec
    * Notion of "collection" ARKs, "item" ARKs, and "representation" ARKs
  * All searchable fields should be indexed in the db, as appropriate
  * Hyphens should be permissible, and yet semantically meaningless, in ARKs
  * Model should verify user's role before any CUD operations

### Model: Validations ###

  * Valid HTTP/HTTPS URL
  * URL get should not return HTTP error
  * uniqueness of fields that should be unique
  * ARK must not already be bound
  * URL must not already be bound
  * Deletions only available to users with most privileged role

<h2>Controller</h2>
<p>
The controllers should take full advantage of the REST and CRUD paradigms, since Rails does them so well.<br>
</p>
```
 Controller.action              -> verb    request             (Noidman action equivalent)
--------------------------------------------------------------------------------------------------------------------
 IdentifiersController.index    -> GET     /identifiers        (view)
 IdentifiersController.new      -> GET     /identifiers;new    (create_form)
 IdentifiersController.create   -> POST    /identifiers        (create) validate, mint, then bind
 IdentifiersController.show     -> GET     /identifiers/1      (-)
 IdentifiersController.edit     -> GET     /identifiers/1;edit (edit)
 IdentifiersController.update   -> PUT     /identifiers/1      (replace) validate, then re-bind
 IdentifiersController.destroy  -> DELETE  /identifiers/1      (delete) [very bad practice, only admins can do this]

?IdentifiersController.resolve  -> GET     /ark:/...           (get)

 UsersController.index          -> GET     /users   
 UsersController. ...
 ContractsController.index      -> GET     /contracts
 ContractsController. ...
 AuthoritiesController.index    -> GET     /authorities 
 AuthoritiesController. ... 
--------------------------------------------------------------------------------------------------------------------
```
<h3>Controller template</h3>
```
class ThingsController < ApplicationController
  before_filter :find_thing, :only => %w( edit show update destroy )

  def index
    @things = Thing.find( :all )
    respond_to do |format|
      format.html # render index.rhtml
      format.rss  { render :action => 'feed.rxml', :layout => false }     
      format.xml  { render :xml => @things.to_xml }
    end
  end

  def resolve
    # stub action for IdentifiersController, resolves /ark:/ identifiers
    redirect_to Identifier.find_by_ark( params[:ark] ).url
  end

  def new
    # render new.rhtml (create form)
    @thing = Thing.new
  end

  def edit
    # render edit.rhtml (edit form)
  end

  def create
    @thing = Thing.create( params[:thing] )
    respond_to do |format|
      format.html { redirect_to( things_path ) }
      format.xml { head :created, :location => thing_path(@thing) }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.xml { render :xml => @thing.to_xml }
    end
  end

  def update
    @thing.update_attributes( params[:thing] )
    respond_to do |format|
      format.html { redirect_to( thing_path( @thing ) ) }
      format.xml  { head :ok }
    end
  end

  def destroy
    @thing.destroy
    respond_to do |format|
      format.html { redirect_to( things_path ) }
      format.xml  { head :ok }
    end
  end

  def find_thing
    @thing = Thing.find( params[:id] )
  end

  private :find_thing
end
```
<h2>View</h2>
<ul><li>Search action and sort option are both view filters (rather than separate actions)<br>
</li><li>Search should look at more than identifier's URL field<br>
</li><li>Include a "My ARKs" page so folks can see what they've created<br>
<ul><li>/users/n/identifiers/<br>
</li></ul></li></ul><h2>Routes</h2>
<p>
Enable all the REST magic via routes.<br>
</p>
```
ActionController::Routing::Routes.draw do |map|
ActionController::Routing::Routes.draw do |map|
  map.resources :bindings
  map.resources :users
  map.resources :roles
  map.resources :contracts
  map.resources :authorities
  map.resources :minters
  
  # --for a model that belongs_to another or others
  # map.resources :things do |things|
  #   things.resources :subthings
  # end
end
end
```