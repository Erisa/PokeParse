# -*- coding: utf-8 -*-
require 'sqlite3'

# Store the lines in the file as array, except for the ones with comments.
lines = File.readlines('pokemon.txt').reject { |x| x.start_with?('#') }

data = []

lines.each do |line|
  line = line.chomp
  if line.start_with?('[')
    @index = line.delete('[').delete(']').chomp.to_i
    data[@index - 1] = {} if data[@index - 1].nil?
    data[@index - 1]['ID'] = @index
  else
    next if @index.nil?
    arr = line.split('=')

    if arr[0] == 'BaseStats'
      stats = arr[1].split(',')
      # You want different stat orders? You got different stat orders!
      statorder = []
      File.readlines('Stat Order.txt').each { |x| statorder.push(x.chomp) }
      x = 0
      statorder.each do |stat|
        data[@index - 1][stat] = stats[x].chomp.to_i
        x += 1
      end
      next
    end

    data[@index - 1][arr[0]] = arr[1].to_s.chomp
  end
end
if File.exist?('pokemon.db')
  puts '[WARN] Existing Databse found, deleting..'
  File.delete('pokemon.db')
end

db = SQLite3::Database.new 'pokemon.db'

db.execute <<-SQL
    create table if not exists pokemondata (
      ID int,
      Name varchar,
      InternalName varchar,
      Type1 varchar,
      Type2 varchar,
      HP int,
      Attack int,
      Defense int,
      Speed int,
      "Special Attack" int,
      "Special Defense" int,
      GenderRate varchar,
      GrowthRate varchar,
      BaseEXP int,
      EffortPoints varchar,
      Rareness int,
      Happiness int,
      Abilities varchar,
      HiddenAbility varchar,
      Moves varchar,
      EggMoves varchar,
      Compatibility varchar,
      StepsToHatch int,
      Height float,
      Weight float,
      Color varchar,
      Shape int,
      Habitat varchar,
      RegionalNumbers varchar,
      Kind varchar,
      Pokedex varchar,
      WildItemCommon varchar,
      WildItemUncommon varchar,
      WildItemRare varchar,
      BattlerPlayerY int,
      BattlerEnemyY int,
      BattlerAltitude int,
      FormName varchar,
      Evolutions varchar,
      Incense varchar
    );
SQL

data.each do |pokemon|
  keys = []
  values = []
  pokemon.each do |key, value|
    puts "Adding #{value} to Database!" if key == 'Name'
    keys.push(key)
    values.push(value)
  end
  db.execute "insert into pokemondata ( \"#{keys.join('", "')}\"  ) values (\" #{values.join('", "')} \")"
end
