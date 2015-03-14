# Arkham: ARK Application Ideas #

<p>
I'm using this document to flesh out some ideas about a new Rails application for management of ARK-compliant persistent identifiers, Arkham.  Arkham is intended to replace <a href='Noidman'>Noidman</a>, a hastily cobbled together Rails front-end to the Perl-based NOID tool developed by the CDL.  Noidman serves its purpose well but is more tightly coupled to the noid tool than I would like, and prevents taking full advantage of Rails models.<br>
</p>
<p>
Why "Arkham?"  First, it's one of the few English words that begin with "ARK" and do not relate to the state of Arkansas.  Second, it's a geeky reference to Batman and H.P. Lovecraft.  And third, it's a homophone for "ARK 'em", as in "Got URLs?  ARK 'em!"<br>
</p>
<p>
The ArkhamFuture describes a fully RESTful ARK web application and service/API that could be implemented by the broader ARK community, and was my first effort to refactor <a href='Noidman.md'>Noidman</a>; alas, it was a bit too ambitious for current development.  I am scaling back and proceeding with a "mostly RESTful" web application for Princeton's specific needs, and periodically sketching out ideas for the ArkhamFuture.<br>
</p>
<p>
When Arkham is ready for release, you may check the code out freely:<br>
</p>
```
svn checkout http://noidman.googlecode.com/svn/branches/arkham/ arkham-read-only  
```
<p>
In the meantime, you may browse the <a href='http://code.google.com/p/noidman/source/browse/#svn/branches/arkham'>source code</a> as it develops.<br>
</p>
<h2>Summary</h2>
<p>
The ARK service allows ARKs -- managed, persistent, and globally unique identifiers -- to be created for URLs.  Each ARK may also have a statement of persistence support ("contract") and a metadata record attached, but are optional.  Other fields may also be attached; our catalogers and metadata specialists have requested a "comment" field, for instance.<br>
</p>
<p>
Arkham<br>
</p>
<ul><li>is being designed primarily for our use at the Princeton University Library, but there is interest in such an application outside of Princeton.  There is a "future" branch which will implement ideas from <a href='ArkhamFuture'>ArkhamFuture</a>, but that is months away.<br>
</li><li>may make use of role-based authorization, though that may not be necessary now that I scaled back the requirements.<br>
</li><li>should be fully compliant with the <a href='http://www.cdlib.org/inside/diglib/ark/arkspec.pdf'><span>ARK specification (PDF)</span></a>, though it may only implement the common bits of the spec we're using at Princeton and defer the rest to <a href='ArkhamFuture'>ArkhamFuture</a>.<br>
</li><li>is available under the <a href='http://en.wikipedia.org/wiki/MIT_License'><span>MIT/X11 License</span></a>.<br>
</li></ul><h3>Generalized schema</h3>
<ul><li>Service has one authority<br>
<ul><li>Authority has many identifiers<br>
<ul><li>Identifiers are unique<br>
</li></ul></li></ul></li><li>Service has many users<br>
<ul><li>User has many identifiers<br>
</li></ul></li><li>Service has many contracts<br>
<ul><li>Contract has many identifiers<br>
</li></ul></li></ul><h2>Model</h2>
<h3>Naive domain model</h3>
```
class Identifier < ActiveRecord::Base
  belongs_to :user
  belongs_to :contract
  belongs_to :authority

  validates_presence_of :ark, :url, :user_id, :authority_id
  validates_uniqueness_of :ark, :url

  def validate
    begin
      uri = URI.parse(url)
    rescue URI::InvalidURIError
      errors.add(:url, 'Invalid URL!')
    end
  end
end
```
```
class User > ActiveRecord::Base
  has_many :identifiers
  validates_presence_of :name, :password, :email
end
```
```
class Contract > ActiveRecord::Base
  has_many :identifiers
  validates_presence_of :statement, :label
end
```
```
class Authority > ActiveRecord::Base
  has_many :identifiers
  validates_presence_of :number, :label
  validates_uniqueness_of :number, :label
  validates_numericality_of :number
  # XXX an identifier must be minted and returned prior to the ActiveRecord::Base#create method invocation
  def mint
    ArkUtils.mint( self )
  end
end
```
<h3>Utility classes</h3>
```
class ArkUtils
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
<h3>Generators</h3>
```
  script/generate scaffold_resource Identifier ark:string url:string comment:text metadata:text authority_id:integer contract_id:integer user_id:integer created_at:datetime updated_at:datetime
  script/generate scaffold_resource User name:string password:string email:string admin:boolean created_at:datetime updated_at:datetime
  script/generate scaffold_resource Contract statement:text label:string created_at:datetime updated_at:datetime 
  script/generate scaffold_resource Authority number:integer label:string created_at:datetime updated_at:datetime
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
      t.column :authority_id, :integer, :null => false
      t.column :contract_id, :integer
      t.column :user_id, :integer, :null => false
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
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
      t.column :password, :string, :null => false
      t.column :email, :string, :null => false
      t.column :admin, :boolean, :default => false
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :users
  end
end
```
```
class CreateContracts < ActiveRecord::Migration
  def self.up
    create_table :contracts do |t|
      t.column :statement, :text, :null => false
      t.column :label, :string, :null => false
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :contracts
  end
end
```
```
class CreateAuthorities < ActiveRecord::Migration
  def self.up
    create_table :authorities do |t| 
      t.column :number, :integer, :null => false
      t.column :label, :string, :null => false
      t.column :host, :string, :null => false
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
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
    add_index :users, :name
    add_index :contracts, :label
    add_index :authorities, :label
    add_index :authorities, :number
  end

  def self.down
    remove_index :identifiers, :ark
    remove_index :identifiers, :url
    remove_index :users, :name
    remove_index :contracts, :label
    remove_index :authorities, :number
    remove_index :authorities, :label
  end
end
```
<h3>Initial data creation</h3>
<p>
XXX insert fixtures here?<br>
</p>
```
class AddTestData < ActiveRecord::Migration
  def self.up
    contract = Contract.create :statement => 'yada yada yada', 
      :label =>  'Ridiculous statement'
    authority = Authority.create :number => 88435, 
      :label => 'Princeton University Library', 
      :host => 'arks.princeton.edu'
    user = User.create :name => 'Michael J. Giarlo', 
      :password =>  'test', 
      :email => 'mgiarlo@princeton.edu',
      :admin => true
    identifier = Identifier.create :ark => authority.mint,
      :url =>  'http://diglib.princeton.edu/',
      :comment => 'This is a comment field.  It is searchable.',
      :authority_id => authority.id,
      :user_id => user.id,
      :contract_id => contract.id
  end

  def self.down
    # find and delete test data
    [Contract.find_by_statement( 'yada yada yada' ), 
     Authority.find_by_number( 88435 ), 
     User.find_by_email( 'mgiarlo@princeton.edu' ), 
     Identifier.find_by_url( 'http://diglib.princeton.edu/' )].each do |object| 
      object.destroy unless object.nil? 
    end
  end
end
```
<h3>Model: Methods and other notes</h3>
<ul><li>It might be nice to have the ability to create multiple authorities (deferred to ArkhamFuture)<br>
</li><li>Model will include all validation methods<br>
</li><li>Model will include methods for minting (delegated to ARK utilities class)<br>
</li><li>Should support variants ('.') and hierarchy ('/') as described in ARK spec (deferred to ArkhamFuture)<br>
<ul><li>Notion of "collection" ARKs, "item" ARKs, and "representation" ARKs (deferred to ArkhamFuture)<br>
</li></ul></li><li>All searchable fields should be indexed in the db as appropriate<br>
</li><li>Hyphens should be permissible, and yet semantically meaningless, in ARKs (deferred to ArkhamFuture)<br>
</li><li>Model should verify user's role before any modifying operations (deferred to ArkhamFuture)<br>
</li></ul><h3>Model: Validations</h3>
<ul><li>Identifiers: Valid HTTP/HTTPS URL<br>
</li></ul><h2>Controller</h2>
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

  map.connect 'ark:/*ark', :controller => 'identifiers', :action => 'resolve'
  map.connect '', :controller => 'arkham', :action => 'index'
  map.connect '/', :controller => 'arkham', :action => 'index'

  map.resources :users do |users| 
    users.resources :identifiers 
  end

  map.resources :contracts do |contracts| 
    contracts.resources :identifiers
  end

  map.resources :authorities do |authorities|  
    authorities.resources :identifiers 
  end

  map.resources :identifiers
end
```