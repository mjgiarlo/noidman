require 'fileutils'
require 'bdb'

class Noid
  attr_reader :noid_id
  
  def initialize( options )
    @noid_id = options[:noid_id]
    @noid_dir = options[:noid_dir]
    @noid_cmd = options[:noid_cmd]
    begin
      FileUtils::chdir @noid_dir
    rescue Exception => err_msg
      # XXX do something appropriate here
    end
  end

  def mint
   @noid_id = %x( #@noid_cmd mint 1 ).scan( /^id:\s+(.+)/ )
  end

  def bind( cmd, field, arg )
    %x( #@noid_cmd bind #{cmd} #@noid_id #{field} '#{arg}' ).scan( /^Status:\s+(.+)/ )
  end

  def get( noid )
    %x( #@noid_cmd get #{noid} location ).chomp
  end

  def get_metadata( noid )
    %x( #@noid_cmd get #{noid} metadata ).chomp
  end

  def get_description( noid )
    %x( #@noid_cmd get #{noid} description ).chomp
  end

  def get_support( noid )
    %x( #@noid_cmd get #{noid} support ).chomp
  end

  def bind_new( url )
    bind( 'new', 'location', url )
  end

  def bind_replace( arg )
    bind( 'replace', 'location', url )
  end
  
  def bind_purge( arg='ignored' )
    bind( 'purge', 'location', url )
  end

  def bind_description( txt )
    bind( 'new', 'description', txt )
  end

  def bind_metadata( md )
    bind( 'new', 'metadata', md )
  end

  def bind_support( support )
    bind( 'new', 'support', support )
  end

  def mint_and_bind( url )
    mint
    bind_new( url )
    @noid_id
  end

  def last_n_mints( n=10 )
    noid_to_cdate_map = []
    noid_db_records = BDB::Btree.open 'NOID/noid.bdb', nil, 'r', {}
    noid_db_records.each do |id, circ|
      next unless id.match( ':/c$' )
      ark = id.sub( /\t:\/c/, '' )
      cdate = circ.split( '|' ).slice( 1 )
      url = get( ark )
      noid_to_cdate_map << [ ark, cdate, url ]
    end
    noid_to_cdate_map.sort { |x, y| y[1] <=> x[1] }.slice( 0, n-1 )
  end

  def get_all( status='bound' )
    minted_noids = {}
    noid_db_records = BDB::Btree.open 'NOID/noid.bdb', nil, 'r', {}
    noid_db_records.each do |id, url|
      next if not id.match('^88435') or id.match(':/c$')
      if url == '1'
        minted_noids[id.sub( /\t:\/h/, '' )] = '' if status != 'bound'
      else
        minted_noids[id.sub( /\tlocation/, '' )] = url if status == 'bound' 
      end
    end
    minted_noids
  end

  def find( query )
    matches = {}
    noid_db_records = BDB::Btree.open 'NOID/noid.bdb', nil, 'r', {}
    noid_db_records.each do |id, url|
      next if id !~ /^88435/ or id =~ /:\/c$/ or url == '1'
      matches[id.sub( /\tlocation/, '' )] = url if url.downcase =~ /#{query.downcase}/
    end
    matches
  end

  def has_minted?( url )
    db = BDB::Btree.open 'NOID/noid.bdb', nil, 'r', {}
    db.has_value?( url ) 
  end

  def minted_by( url )
    db = BDB::Btree.open 'NOID/noid.bdb', nil, 'r', {}
    db.index( url ).sub( /\tlocation/, '' ) if db.has_value?( url )
  end

  def dump_stats
    @db_stats = {}
    db = BDB::Btree.open 'NOID/noid.bdb', nil, 'r', {}
    db.stat.each do |k, v|
      @db_stats.store k, v
    end
    db.close
    @db_stats
  end

  def dump_records
    @db_recs = {}
    db = BDB::Btree.open 'NOID/noid.bdb', nil, 'r', {}
    db.each do |k, v|
      @db_recs.store k, v
    end
    db.close
    @db_recs
  end
end
