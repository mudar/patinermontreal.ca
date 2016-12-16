# coding: utf-8
namespace :import do
  desc 'Add rinks from donnees.ville.montreal.qc.ca'
  task montreal: :environment do
    flip = 1
    Nokogiri::XML(RestClient.get('http://www2.ville.montreal.qc.ca/services_citoyens/pdf_transfert/L29_PATINOIRE.xml')).css('patinoire').each do |node|
      # Add m-dash, except for Ahuntsic-Cartierville.
      nom_arr = node.at_css('nom_arr').text.
        sub('Ahuntsic - Cartierville', 'Ahuntsic-Cartierville').
        sub('Villeray-Saint-Michel - Parc-Extension', 'Villeray—Saint-Michel—Parc-Extension').
        sub('Côte-des-Neiges - Notre-Dame-de-Grâce', 'Côte-des-Neiges—Notre-Dame-de-Grâce').
        sub('L\'Île-Bizard - Sainte-Geneviève', "L'Île-Bizard—Sainte-Geneviève").
        gsub(' - ', '—')

      arrondissement = Arrondissement.find_or_initialize_by_nom_arr(nom_arr)
      arrondissement.cle = node.at_css('cle').text
      arrondissement.date_maj = Time.parse node.at_css('date_maj').text
      arrondissement.source = 'donnees.ville.montreal.qc.ca'

      begin
        arrondissement.save!

        # Expand/correct rink names to avoid later parsing errors
        xml_name = node.at_css('nom').text.sub(' du parc ', ', parc ').gsub(/([a-z])\sparc/im, '\1, parc').gsub(/bleu(.*)blanc(.*)bouge/im, 'Bleu-Blanc-Bouge').strip
        xml_name = 'Patinoire Bleu-Blanc-Bouge, parc de la Confédération (PSE)' if xml_name == 'Patinoire Bleu-Blanc-Bouge (PSE)' && arrondissement.cle == 'cdn' 
        xml_name = 'Patinoire de patin libre, parc du Glacis (PP)' if xml_name == 'Patinoire du Glacis (PP)'
        xml_name = 'Patinoire décorative, Toussaint-Louverture (PP)' if xml_name == 'Patinoire décorative Toussaint-Louverture (PP)'
        xml_name = 'Patinoire extérieure, Domaine Chartier (PPL)' if xml_name == 'Patinoire extérieure Domaine Chartier (PPL)'
        xml_name = 'Patinoire décorative, C.E.C. René-Goupil (PP)' if xml_name == 'Centre comm R-Goupil, Patinoire décorative (PP)'
        xml_name = 'Patinoire avec bandes, De Gaspé/Bernard (PSE)' if xml_name == 'Patinoire De Gaspé/Bernard (PSE)'
        xml_name = 'Patinoire décorative, parc Aimé-Léonard (PP)' if xml_name == 'Patinoire, parc Aimé-Léonard (PP)'

        patinoire = Patinoire.find_or_initialize_by_nom_and_arrondissement_id(xml_name, arrondissement.id)
        %w(ouvert deblaye arrose resurface condition).each do |attribute|
          patinoire[attribute] = node.at_css(attribute).text
          patinoire[attribute] = (attribute == 'condition'? 'N/A' : false) if (patinoire[attribute].nil?)
        end

        description = case patinoire.nom
        when 'Patinoire bandes Pierre-Bédard (PSE)', 'patinoire extérieure (PSE)'
          'Patinoire avec bandes'
        when /(.*)Bleu\-Blanc\-Bouge(.*)/
          'Patinoire réfrigérée Bleu-Blanc-Bouge'
        when 'Patinoire de parin libre, parc Sauvé (PPL)'
          'Patinoire de patin libre'
        else
          patinoire.nom[/\A(.+?) ?(?:no [1-3]|nord|sud)?(?:,|-| du parc\b)/, 1] || patinoire.nom
        end

        patinoire.description = {
          'Anneau à patiner'           => 'Anneau de glace',
          'Pat. avec bandes'           => 'Patinoire avec bandes',
          'Pati déco'                  => 'Patinoire décorative',
          'Patinoire à bandes'         => 'Patinoire avec bandes',
          'Patnoire à bandes'          => 'Patinoire avec bandes',
          'Patinoire avec bande'       => 'Patinoire avec bandes',
          'Patinoire bandes'           => 'Patinoire avec bandes',
          'Patinoire ext. avec bandes' => 'Patinoire avec bandes',
        }.reduce(description) do |string,(from,to)|
          string.sub(/#{Regexp.escape from}\z/, to)
        end

        patinoire.genre = patinoire.nom[/\((PP|PPL|PSE)\)\z/, 1]

        patinoire.disambiguation = (patinoire.nom[/\A(Petite|Grande)\b/i, 1] || patinoire.nom[/[^-]\b(nord|sud|no \d)\b/i, 1]).andand.downcase
#        patinoire.disambiguation ||= "bbb-canadiens" if patinoire.nom[/(Bleu(\W)?Blanc(\W)?Bouge\b)|(\bBBB\b)\b/i, 1]
        patinoire.disambiguation ||= "no #{$1}" if patinoire.nom[/ (\d),/, 1]
        patinoire.disambiguation ||= 'réfrigérée' if patinoire.description == 'Patinoire réfrigérée' || patinoire.description == 'Patinoire réfrigérée Bleu-Blanc-Bouge'

        # Expand/correct park names.
        parc = patinoire.nom[/, ([^(]+?)(?: no \d)? \(/, 1] || patinoire.nom[/ du parc (.+) \(/, 1] || patinoire.nom[/(.+) \(/, 1]
        patinoire.parc = {
          'C-de-la-Rousselière'              => 'Clémentine-De La Rousselière',
          'Cité-Jardin'                      => 'de la Cité Jardin',
          'de la Rive-Boisé'                 => 'de la Rive-Boisée',
          'De la Petite-Italie'              => 'Petite Italie',
          'Des Hirondelles'                  => 'des Hirondelles',
          'Duff court'                       => 'Duff Court',
          'François-Perrault-réfr'           => 'François-Perrault',
          'Ignace-Bourget-anneau de vitesse' => 'Ignace-Bourget',
          'lalancette'                       => 'Lalancette',
          'Lac aux Castors'                  => 'Lac aux Castors',
          'Lac aux castors'                  => 'Lac aux Castors',
          'Lac des castors'                  => 'Lac aux Castors',
          'Marc-Aurèle-Fortin'               => 'Hans-Selye',
          'Patinoire bandes Pierre-Bédard'   => 'Pierre-Bédard',
          'Saint-Aloysis'                    => 'Saint-Aloysius',
          'Sainte-Maria-Goretti'             => 'Maria-Goretti',
          'Y-Thériault/Sherbrooke'           => 'Yves-Thériault/Sherbrooke',
          'Roger Rousseau'                   => 'Roger-Rousseau',
          'De Gaspé/Bernard'                 => 'Champ des possibles',
          # Need to do independent research to find where these are.
          'patinoire extérieure'             => ''
        }.reduce(parc) do |string,(from,to)|
          string.sub(/#{Regexp.escape from}\z/, to)
        end
        patinoire.parc.slice!(/\AParc /i)

        # Remove disambiguation from description.
        patinoire.description.slice!(/ (\d|Nord|Sud)\z/)

        # "Aire de patinage libre" with "PSE" is nonsense.
        if patinoire.nom == 'Aire de patinage libre, Kent (sud) (PSE)'
          patinoire.genre = 'PPL'
        end

        # There is no "no 2".
        if patinoire.nom == 'Patinoire de patin libre, Le Prévost no 1 (PPL)'
          patinoire.parc = 'Le Prévost'
          patinoire.disambiguation = nil
        end
        
        # There is no "no 2", also require a valid description
        if ['Patinoire # 1, Parc Jonathan-Wilson (PSE)', 'Patinoire # 1, Parc Joseph-Avila-Proulx (PSE)', 'Patinoire # 1, Parc Robert-Sauvé (PSE)'].include? patinoire.nom
          patinoire.disambiguation = nil
          patinoire.description = 'Patinoire de hockey'
        end
        
        # Require a valid description
        if ['Patinoire # 2 , Parc Eugène-Dostie (PSE)', 'Patinoire # 1 , Parc Eugène-Dostie (PSE)'].include? patinoire.nom
          patinoire.description = 'Patinoire de hockey'
        end

        # There are identical lines.
        if patinoire.parc == 'LaSalle' && patinoire.genre == 'PSE'
          patinoire.disambiguation = "no #{flip}"
          flip = flip == 1 ? 2 : 1
        end
        
        patinoire.source = 'donnees.ville.montreal.qc.ca'
        begin
          patinoire.save!
        rescue => e
          puts "#{e.inspect}: #{patinoire.inspect}"
        end
      rescue => e
        puts "#{e.inspect}: #{arrondissement.inspect}"
      end
    end
  end

  desc 'Add rinks from montreal-west.ca'
  task montrealwest: :environment do
    arrondissement = Arrondissement.find_or_initialize_by_nom_arr('Montréal-Ouest')
    arrondissement.source = 'montreal-west.ca'
    arrondissement.date_maj = Time.now
    arrondissement.save!

    # http://www.montreal-west.ca/en/outdoor-rinks/
    Nokogiri::HTML(RestClient.get('http://www.montreal-west.ca/fr/patinoires-exterieur/')).css('table[border] tr:gt(1)').each do |tr|
      text = tr.at_css('td:eq(1)').text.gsub(/[[:space:]]/, ' ').strip
      attributes = case text
      when 'Terrain Hodgson - Patinoire'
        {
          parc: 'Hodgson',
          genre: 'PPL',
          arrondissement_id: arrondissement.id,
        }
      when 'Terrain Hodgson - Patinoire de hockey'
        {
          parc: 'Hodgson',
          genre: 'PSE',
          arrondissement_id: arrondissement.id,
        }
      when 'Parc Rugby'
        {
          parc: 'Rugby',
          genre: 'PPL',
          arrondissement_id: arrondissement.id,
        }
      else
        puts "Unknown rink '#{text}'"
        next
      end

      # conditions are not updated anymore
      attributes.merge!({
#         ouvert: tr.at_css('td:eq(2)').text.gsub(/[[:space:]]/, ' ').strip == 'oui',
#         deblaye: tr.at_css('td:eq(3)').text.gsub(/[[:space:]]/, ' ').strip == 'oui',
#         arrose: tr.at_css('td:eq(4)').text.gsub(/[[:space:]]/, ' ').strip == 'oui',
        source: 'montreal-west.ca',
      })

#       condition = tr.at_css('td:eq(5)').text.gsub(/[[:space:]]/, ' ').strip
#       attributes[:condition] = case condition
#       when 'excellente', 'Excellent'
#         'Excellente'
#       when 'bonne', 'Bon'
#         'Bonne'
#       when 'mauvaise'
#         'Mauvaise'
#       else
#         puts "Unknown condition '#{condition}'" unless condition.blank?
#         'N/A'
#       end

      patinoire = Patinoire.find_or_initialize_by_parc_and_genre_and_arrondissement_id attributes[:parc], attributes[:genre], arrondissement.id
      patinoire.attributes = attributes
      patinoire.save!
    end
  end

  # Dorval changed the location and layout of their page.
  # desc 'Add rinks from ville.dorval.qc.ca'
  # task dorval: :environment do
  #   arrondissement = Arrondissement.find_or_initialize_by_nom_arr('Dorval')
  #   arrondissement.source = 'ville.dorval.qc.ca'
  #   arrondissement.date_maj = Time.now
  #   arrondissement.save!

  #   Nokogiri::HTML(RestClient.get('http://www.ville.dorval.qc.ca/loisirs/fr/default.asp?contentID=808')).css('tr:gt(2)').each do |tr|
  #     condition = 'N/A'
  #     { 4 => 'Excellente',
  #       5 => 'Bonne',
  #       6 => 'Mauvaise',
  #     }.each do |i,v|
  #       if tr.at_css("td:eq(#{i})").text.gsub(/[[:space:]]/, '').present?
  #         condition = v
  #       end
  #     end

  #     begin
  #       text = tr.at_css('td:eq(1)').text
  #       attributes = {
  #         genre: text['Patinoire récréative et de hockey'] ? 'PSE' : 'PPL',
  #         parc: tr.at_css('b').text.sub(/\AParc /, ''),
  #         adresse: tr.at_css('p').children[1].text,
  #         tel: text[/\(514\) \d{3}-\d{4}/].delete('^0-9'),
  #         ouvert: tr.at_css('td:eq(2)').text.gsub(/[[:space:]]/, '').present?,
  #         condition: condition,
  #         source: 'ville.dorval.qc.ca',
  #       }

  #       patinoire = Patinoire.find_or_initialize_by_parc_and_genre_and_arrondissement_id(attributes[:parc], attributes[:genre], arrondissement.id)
  #       patinoire.attributes = attributes
  #       patinoire.save!

  #       if text['Patinoire récréative et de hockey']
  #         patinoire = Patinoire.find_or_initialize_by_parc_and_genre_and_arrondissement_id(attributes[:parc], 'PPL', arrondissement.id)
  #         patinoire.attributes = attributes.merge(genre: 'PPL')
  #         patinoire.save!
  #       end
  #     rescue => e
  #       puts "#{e.inspect}: #{tr.to_s}"
  #     end
  #   end
  # end
  
  # desc 'Add rinks from www.longueuil.quebec'
  task longueuil: :environment do
    doc = Nokogiri::HTML(RestClient.get('https://www.longueuil.quebec/fr/conditions-sites-hivernaux-vieux-longueuil'))
    
    # Vieux-Longueuil conditions
    
    arrondissement = Arrondissement.find_or_initialize_by_nom_arr('Vieux-Longueuil')
    arrondissement.source = 'www.longueuil.quebec'
    arrondissement.date_maj = Time.now
    arrondissement.save!
   
    # First table: Sentiers de ski de fond et pentes à glisser  
    tr = doc.css('.field-name-body table:eq(1)').css('tr:eq(7)')
    attributes = { 
      parc: 'Michel-Chartrand',
      genre: 'PSE',
      ouvert: tr.css("td:eq(4)").text.downcase().include?('x') ,
      resurface: tr.css("td:eq(2)").text.downcase().include?('x') ,
      condition: 'N/A'
    }

    attributes[:condition] = 'Excellente' if tr.css("td:eq(4)").text.downcase().include?('x')
    attributes[:condition] = 'Bonne' if tr.css("td:eq(5)").text.downcase().include?('x')
    
    # Fix for "passable" but not "open"
    attributes[:ouvert] = true if attributes[:condition] == 'Bonne'
    
    patinoire = Patinoire.find_or_initialize_by_parc_and_genre_and_arrondissement_id(attributes[:parc], attributes[:genre], arrondissement.id)
    patinoire.attributes = attributes.merge({source: 'www.longueuil.quebec'})
    patinoire.save!

    # Second table: Patinoire réfrigérée BBB
    tr = doc.css('.field-name-body table:eq(2)').css('tr:eq(3)')
    attributes = import_html_table_row tr, nil
    attributes[:parc] = 'Lionel-Groulx'

    patinoire = Patinoire.find_or_initialize_by_description_and_parc_and_arrondissement_id('Patinoire réfrigérée Bleu-Blanc-Bouge', 'Lionel-Groulx', arrondissement.id)
    patinoire.attributes = attributes.merge({source: 'www.longueuil.quebec'})
    patinoire.save!
    
    # Third table: Patinoires et surfaces glacées 
    previous = ''
    doc.css('.field-name-body table:eq(3)').css('tr:gt(2)').each do |tr|
      attributes = import_html_table_row tr, previous
      previous = attributes[:parc]
      
      patinoire = Patinoire.find_or_initialize_by_parc_and_genre_and_arrondissement_id(attributes[:parc], attributes[:genre], arrondissement.id)
      patinoire.attributes = attributes.merge({source: 'www.longueuil.quebec'})
      patinoire.save!
    end
        
    # Saint-Hubert conditions
    
    arrondissement = Arrondissement.find_or_initialize_by_nom_arr('Saint-Hubert')
    arrondissement.source = 'www.longueuil.quebec'
    arrondissement.date_maj = Time.now 
    arrondissement.save!
   
    # First table: Sentiers de ski de fond et pentes à glisser  
    tr = doc.css('.field-name-body table:eq(4)').css('tr:gt(6)').each do |tr|
      spanned = tr.css('> td').count == 6 
      offset = spanned ? -1 : 0
      attributes = { 
        parc: 'de la Cité',
        ouvert: tr.css("td:eq(#{5+offset})").text.downcase().include?('x') ,
        resurface: tr.css("td:eq(#{3+offset})").text.downcase().include?('x') ,
        condition: 'N/A'
      }
      attributes[:genre] = 'PPL' if tr.css("td:eq(#{2+offset})").text == 'Pavillon'
      attributes[:genre] = 'PP' if tr.css("td:eq(#{2+offset})").text == 'Bois'
      
      attributes[:condition] = 'Excellente' if tr.css("td:eq(#{5+offset})").text.downcase().include?('x')
      attributes[:condition] = 'Bonne' if tr.css("td:eq(#{6+offset})").text.downcase().include?('x')

      # Fix for "passable" but not "open"
      attributes[:ouvert] = true if attributes[:condition] == 'Bonne'
      
      patinoire = Patinoire.find_or_initialize_by_parc_and_genre_and_arrondissement_id(attributes[:parc], attributes[:genre], arrondissement.id)
      patinoire.attributes = attributes.merge({source: 'www.longueuil.quebec'})
      patinoire.save!
    end

    # Second table: Patinoires et surfaces glacées 
    previous = ''
    doc.css('.field-name-body table:eq(5)').css('tr:gt(2)').each do |tr|
      attributes = import_html_table_row tr, previous
      previous = attributes[:parc]

      patinoire = Patinoire.find_or_initialize_by_parc_and_genre_and_arrondissement_id(attributes[:parc], attributes[:genre], arrondissement.id)
      patinoire.attributes = attributes.merge({source: 'www.longueuil.quebec'})
      patinoire.save!
    end
  end
  
  def import_html_table_row(tr, previous_parc)
    spanned = tr.css('> td').count == 4 
    offset = spanned ? -1 : 0
    nom = tr.css("td:eq(#{2+offset})").text.gsub(/[[:space:]]/, ' ').strip
    attributes = { 
      parc: spanned ? previous_parc : tr.at_css('td').text.gsub(/[[:space:]]/, ' ').sub('Parc ', '').strip ,
      genre: case nom
      when 'Surface glacée', 'Suface glacée'
        'PPL'
      when 'Patinoire'
        'PSE'
      else  
        puts "Unknown rink '#{nom}'"
        abort 
      end ,
      ouvert: tr.css("td:eq(#{3+offset})").text.downcase().include?('x') ,
      condition: 'N/A'
    }

    attributes[:condition] = 'Excellente' if tr.css("td:eq(#{3+offset})").text.downcase().include?('x')
    attributes[:condition] = 'Bonne' if tr.css("td:eq(#{4+offset})").text.downcase().include?('x')
    
    # Fix for "passable" but not "open"
    attributes[:ouvert] = true if attributes[:condition] == 'Bonne'
    
    return attributes
  end
end