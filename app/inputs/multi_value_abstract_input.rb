# [hyc-override] Overriding hydra editor custom input to allow for multivalue HTML5 dates
# https://github.com/samvera/hydra-editor/blob/master/app/inputs/multi_value_input.rb
class MultiValueAbstractInput < SimpleForm::Inputs::CollectionInput
  def input(wrapper_options)
    @rendered_first_element = false
    input_html_classes.unshift('string')
    input_html_options[:name] ||= "#{object_name}[#{attribute_name}][]"

    outer_wrapper do
      buffer_each(collection) do |valuex, index|
        inner_wrapper do
          build_field(valuex, index)
        end
      end
    end
  end

  protected

  def buffer_each(collection)
    collection.each_with_object('').with_index do |(value, buffer), index|
      buffer << yield(value, index)
    end
  end

  def outer_wrapper
     "    <ul class=\"listing\">\n        #{yield}\n      </ul>\n"
  end
 

  def inner_wrapper
    <<-HTML
          <li class="field-wrapper">
            #{yield}
            <div class="form-group field-wrapper input-group input-append  multi_value optional #{object_name}_abstract managed" style="width:20%;background-color:inherit;vertical-align:bottom;padding:0;border-radius:0;border:none;">
              <select class="string multi_value optional form-control #{object_name}_abstract multi-text-field select_abstract" id="#{object_name}_abstract" name="#{object_name}[abstract][]">
                          <option value="&quot;@en">English</option>
                          <option value="&quot;@aa">Afar</option>
                          <option value="&quot;@ab">Abkhazian</option>
                          <option value="&quot;@ac">Achinese</option>
                          <option value="&quot;@ac">Acoli</option>
                          <option value="&quot;@ad">Adangme</option>
                          <option value="&quot;@ad">Adyghe | Adygei</option>
                          <option value="&quot;@af">Afro-Asiatic languages</option>
                          <option value="&quot;@af">Afrihili</option>
                          <option value="&quot;@af">Afrikaans</option>
                          <option value="&quot;@ai">Ainu</option>
                          <option value="&quot;@ak">Akan</option>
                          <option value="&quot;@ak">Akkadian</option>
                          <option value="&quot;@al">Albanian</option>
                          <option value="&quot;@al">Aleut</option>
                          <option value="&quot;@al">Algonquian languages</option>
                          <option value="&quot;@al">Southern Altai</option>
                          <option value="&quot;@am">Amharic</option>
                          <option value="&quot;@an">English, Old (ca.450-1100)</option>
                          <option value="&quot;@an">Angika</option>
                          <option value="&quot;@ap">Apache languages</option>
                          <option value="&quot;@ar">Arabic</option>
                          <option value="&quot;@ar">Official Aramaic (700-300 BCE) | Imperial Aramaic (700-300 BCE)</option>
                          <option value="&quot;@ar">Aragonese</option>
                          <option value="&quot;@ar">Armenian</option>
                          <option value="&quot;@ar">Mapudungun | Mapuche</option>
                          <option value="&quot;@ar">Arapaho</option>
                          <option value="&quot;@ar">Artificial languages</option>
                          <option value="&quot;@ar">Arawak</option>
                          <option value="&quot;@as">Assamese</option>
                          <option value="&quot;@as">Asturian | Bable | Leonese | Asturleonese</option>
                          <option value="&quot;@at">Athapascan languages</option>
                          <option value="&quot;@au">Australian languages</option>
                          <option value="&quot;@av">Avaric</option>
                          <option value="&quot;@av">Avestan</option>
                          <option value="&quot;@aw">Awadhi</option>
                          <option value="&quot;@ay">Aymara</option>
                          <option value="&quot;@az">Azerbaijani</option>
                          <option value="&quot;@ba">Banda languages</option>
                          <option value="&quot;@ba">Bamileke languages</option>
                          <option value="&quot;@ba">Bashkir</option>
                          <option value="&quot;@ba">Baluchi</option>
                          <option value="&quot;@ba">Bambara</option>
                          <option value="&quot;@ba">Balinese</option>
                          <option value="&quot;@ba">Basque</option>
                          <option value="&quot;@ba">Basa</option>
                          <option value="&quot;@ba">Baltic languages</option>
                          <option value="&quot;@be">Beja | Bedawiyet</option>
                          <option value="&quot;@be">Belarusian</option>
                          <option value="&quot;@be">Bemba</option>
                          <option value="&quot;@be">Bengali</option>
                          <option value="&quot;@be">Berber languages</option>
                          <option value="&quot;@bh">Bhojpuri</option>
                          <option value="&quot;@bi">Bihari languages</option>
                          <option value="&quot;@bi">Bikol</option>
                          <option value="&quot;@bi">Bini | Edo</option>
                          <option value="&quot;@bi">Bislama</option>
                          <option value="&quot;@bl">Siksika</option>
                          <option value="&quot;@bn">Bantu languages</option>
                          <option value="&quot;@bo">Tibetan</option>
                          <option value="&quot;@bo">Bosnian</option>
                          <option value="&quot;@br">Braj</option>
                          <option value="&quot;@br">Breton</option>
                          <option value="&quot;@bt">Batak languages</option>
                          <option value="&quot;@bu">Buriat</option>
                          <option value="&quot;@bu">Buginese</option>
                          <option value="&quot;@bu">Bulgarian</option>
                          <option value="&quot;@bu">Burmese</option>
                          <option value="&quot;@by">Blin | Bilin</option>
                          <option value="&quot;@ca">Caddo</option>
                          <option value="&quot;@ca">Central American Indian languages</option>
                          <option value="&quot;@ca">Galibi Carib</option>
                          <option value="&quot;@ca">Catalan | Valencian</option>
                          <option value="&quot;@ca">Caucasian languages</option>
                          <option value="&quot;@ce">Cebuano</option>
                          <option value="&quot;@ce">Celtic languages</option>
                          <option value="&quot;@ce">Czech</option>
                          <option value="&quot;@ch">Chamorro</option>
                          <option value="&quot;@ch">Chibcha</option>
                          <option value="&quot;@ch">Chechen</option>
                          <option value="&quot;@ch">Chagatai</option>
                          <option value="&quot;@ch">Chinese</option>
                          <option value="&quot;@ch">Chuukese</option>
                          <option value="&quot;@ch">Mari</option>
                          <option value="&quot;@ch">Chinook jargon</option>
                          <option value="&quot;@ch">Choctaw</option>
                          <option value="&quot;@ch">Chipewyan | Dene Suline</option>
                          <option value="&quot;@ch">Cherokee</option>
                          <option value="&quot;@ch">Church Slavic | Old Slavonic | Church Slavonic | Old Bulgarian | Old Church Slavonic  </option>
                          <option value="&quot;@ch">Chuvash</option>
                          <option value="&quot;@ch">Cheyenne</option>
                          <option value="&quot;@cm">Chamic languages</option>
                          <option value="&quot;@cn">Montenegrin</option>
                          <option value="&quot;@co">Coptic</option>
                          <option value="&quot;@co">Cornish</option>
                          <option value="&quot;@co">Corsican</option>
                          <option value="&quot;@cp">Creoles and pidgins, English based</option>
                          <option value="&quot;@cp">Creoles and pidgins, French-based</option>
                          <option value="&quot;@cp">Creoles and pidgins, Portuguese-based</option>
                          <option value="&quot;@cr">Cree</option>
                          <option value="&quot;@cr">Crimean Tatar | Crimean Turkish</option>
                          <option value="&quot;@cr">Creoles and pidgins</option>
                          <option value="&quot;@cs">Kashubian</option>
                          <option value="&quot;@cu">Cushitic languages</option>
                          <option value="&quot;@cy">Welsh</option>
                          <option value="&quot;@cz">Czech</option>
                          <option value="&quot;@da">Dakota</option>
                          <option value="&quot;@da">Danish</option>
                          <option value="&quot;@da">Dargwa</option>
                          <option value="&quot;@da">Land Dayak languages</option>
                          <option value="&quot;@de">Delaware</option>
                          <option value="&quot;@de">Slave (Athapascan)</option>
                          <option value="&quot;@de">German</option>
                          <option value="&quot;@dg">Dogrib</option>
                          <option value="&quot;@di">Dinka</option>
                          <option value="&quot;@di">Divehi | Dhivehi | Maldivian</option>
                          <option value="&quot;@do">Dogri</option>
                          <option value="&quot;@dr">Dravidian languages</option>
                          <option value="&quot;@ds">Lower Sorbian</option>
                          <option value="&quot;@du">Duala</option>
                          <option value="&quot;@du">Dutch, Middle (ca.1050-1350)</option>
                          <option value="&quot;@du">Dutch | Flemish</option>
                          <option value="&quot;@dy">Dyula</option>
                          <option value="&quot;@dz">Dzongkha</option>
                          <option value="&quot;@ef">Efik</option>
                          <option value="&quot;@eg">Egyptian (Ancient)</option>
                          <option value="&quot;@ek">Ekajuk</option>
                          <option value="&quot;@el">Greek, Modern (1453-)</option>
                          <option value="&quot;@el">Elamite</option>
                          <option value="&quot;@en">English, Middle (1100-1500)</option>
                          <option value="&quot;@ep">Esperanto</option>
                          <option value="&quot;@es">Estonian</option>
                          <option value="&quot;@eu">Basque</option>
                          <option value="&quot;@ew">Ewe</option>
                          <option value="&quot;@ew">Ewondo</option>
                          <option value="&quot;@fa">Fang</option>
                          <option value="&quot;@fa">Faroese</option>
                          <option value="&quot;@fa">Persian</option>
                          <option value="&quot;@fa">Fanti</option>
                          <option value="&quot;@fi">Fijian</option>
                          <option value="&quot;@fi">Filipino | Pilipino</option>
                          <option value="&quot;@fi">Finnish</option>
                          <option value="&quot;@fi">Finno-Ugrian languages</option>
                          <option value="&quot;@fo">Fon</option>
                          <option value="&quot;@fr">French</option>
                          <option value="&quot;@fr">French</option>
                          <option value="&quot;@/f">French</option>
                          <option value="&quot;@fr">French, Middle (ca.1400-1600)</option>
                          <option value="&quot;@fr">French, Old (842-ca.1400)</option>
                          <option value="&quot;@fr">Northern Frisian</option>
                          <option value="&quot;@fr">Eastern Frisian</option>
                          <option value="&quot;@fr">Western Frisian</option>
                          <option value="&quot;@fu">Fulah</option>
                          <option value="&quot;@fu">Friulian</option>
                          <option value="&quot;@ga">Ga</option>
                          <option value="&quot;@ga">Gayo</option>
                          <option value="&quot;@gb">Gbaya</option>
                          <option value="&quot;@ge">Germanic languages</option>
                          <option value="&quot;@ge">Georgian</option>
                          <option value="&quot;@ge">German</option>
                          <option value="&quot;@ge">Geez</option>
                          <option value="&quot;@gi">Gilbertese</option>
                          <option value="&quot;@gl">Gaelic | Scottish Gaelic</option>
                          <option value="&quot;@gl">Irish</option>
                          <option value="&quot;@gl">Galician</option>
                          <option value="&quot;@gl">Manx</option>
                          <option value="&quot;@gm">German, Middle High (ca.1050-1500)</option>
                          <option value="&quot;@go">German, Old High (ca.750-1050)</option>
                          <option value="&quot;@go">Gondi</option>
                          <option value="&quot;@go">Gorontalo</option>
                          <option value="&quot;@go">Gothic</option>
                          <option value="&quot;@gr">Grebo</option>
                          <option value="&quot;@gr">Greek, Ancient (to 1453)</option>
                          <option value="&quot;@gr">Greek, Modern (1453-)</option>
                          <option value="&quot;@gr">Guarani</option>
                          <option value="&quot;@gs">Swiss German | Alemannic | Alsatian</option>
                          <option value="&quot;@gu">Gujarati</option>
                          <option value="&quot;@gw">Gwich'in</option>
                          <option value="&quot;@ha">Haida</option>
                          <option value="&quot;@ha">Haitian | Haitian Creole</option>
                          <option value="&quot;@ha">Hausa</option>
                          <option value="&quot;@ha">Hawaiian</option>
                          <option value="&quot;@he">Hebrew</option>
                          <option value="&quot;@he">Herero</option>
                          <option value="&quot;@hi">Hiligaynon</option>
                          <option value="&quot;@hi">Himachali languages | Western Pahari languages</option>
                          <option value="&quot;@hi">Hindi</option>
                          <option value="&quot;@hi">Hittite</option>
                          <option value="&quot;@hm">Hmong | Mong</option>
                          <option value="&quot;@hm">Hiri Motu</option>
                          <option value="&quot;@hr">Croatian</option>
                          <option value="&quot;@hs">Upper Sorbian</option>
                          <option value="&quot;@hu">Hungarian</option>
                          <option value="&quot;@hu">Hupa</option>
                          <option value="&quot;@hy">Armenian</option>
                          <option value="&quot;@ib">Iban</option>
                          <option value="&quot;@ib">Igbo</option>
                          <option value="&quot;@ic">Icelandic</option>
                          <option value="&quot;@id">Ido</option>
                          <option value="&quot;@ii">Sichuan Yi | Nuosu</option>
                          <option value="&quot;@ij">Ijo languages</option>
                          <option value="&quot;@ik">Inuktitut</option>
                          <option value="&quot;@il">Interlingue | Occidental</option>
                          <option value="&quot;@il">Iloko</option>
                          <option value="&quot;@in">Interlingua (International Auxiliary Language Association)</option>
                          <option value="&quot;@in">Indic languages</option>
                          <option value="&quot;@in">Indonesian</option>
                          <option value="&quot;@in">Indo-European languages</option>
                          <option value="&quot;@in">Ingush</option>
                          <option value="&quot;@ip">Inupiaq</option>
                          <option value="&quot;@ir">Iranian languages</option>
                          <option value="&quot;@ir">Iroquoian languages</option>
                          <option value="&quot;@is">Icelandic</option>
                          <option value="&quot;@it">Italian</option>
                          <option value="&quot;@ja">Javanese</option>
                          <option value="&quot;@jb">Lojban</option>
                          <option value="&quot;@jp">Japanese</option>
                          <option value="&quot;@jp">Judeo-Persian</option>
                          <option value="&quot;@jr">Judeo-Arabic</option>
                          <option value="&quot;@ka">Kara-Kalpak</option>
                          <option value="&quot;@ka">Kabyle</option>
                          <option value="&quot;@ka">Kachin | Jingpho</option>
                          <option value="&quot;@ka">Kalaallisut | Greenlandic</option>
                          <option value="&quot;@ka">Kamba</option>
                          <option value="&quot;@ka">Kannada</option>
                          <option value="&quot;@ka">Karen languages</option>
                          <option value="&quot;@ka">Kashmiri</option>
                          <option value="&quot;@ka">Georgian</option>
                          <option value="&quot;@ka">Kanuri</option>
                          <option value="&quot;@ka">Kawi</option>
                          <option value="&quot;@ka">Kazakh</option>
                          <option value="&quot;@kb">Kabardian</option>
                          <option value="&quot;@kh">Khasi</option>
                          <option value="&quot;@kh">Khoisan languages</option>
                          <option value="&quot;@kh">Central Khmer</option>
                          <option value="&quot;@kh">Khotanese | Sakan</option>
                          <option value="&quot;@ki">Kikuyu | Gikuyu</option>
                          <option value="&quot;@ki">Kinyarwanda</option>
                          <option value="&quot;@ki">Kirghiz | Kyrgyz</option>
                          <option value="&quot;@km">Kimbundu</option>
                          <option value="&quot;@ko">Konkani</option>
                          <option value="&quot;@ko">Komi</option>
                          <option value="&quot;@ko">Kongo</option>
                          <option value="&quot;@ko">Korean</option>
                          <option value="&quot;@ko">Kosraean</option>
                          <option value="&quot;@kp">Kpelle</option>
                          <option value="&quot;@kr">Karachay-Balkar</option>
                          <option value="&quot;@kr">Karelian</option>
                          <option value="&quot;@kr">Kru languages</option>
                          <option value="&quot;@kr">Kurukh</option>
                          <option value="&quot;@ku">Kuanyama | Kwanyama</option>
                          <option value="&quot;@ku">Kumyk</option>
                          <option value="&quot;@ku">Kurdish</option>
                          <option value="&quot;@ku">Kutenai</option>
                          <option value="&quot;@la">Ladino</option>
                          <option value="&quot;@la">Lahnda</option>
                          <option value="&quot;@la">Lamba</option>
                          <option value="&quot;@la">Lao</option>
                          <option value="&quot;@la">Latin</option>
                          <option value="&quot;@la">Latvian</option>
                          <option value="&quot;@le">Lezghian</option>
                          <option value="&quot;@li">Limburgan | Limburger | Limburgish</option>
                          <option value="&quot;@li">Lingala</option>
                          <option value="&quot;@li">Lithuanian</option>
                          <option value="&quot;@lo">Mongo</option>
                          <option value="&quot;@lo">Lozi</option>
                          <option value="&quot;@lt">Luxembourgish | Letzeburgesch</option>
                          <option value="&quot;@lu">Luba-Lulua</option>
                          <option value="&quot;@lu">Luba-Katanga</option>
                          <option value="&quot;@lu">Ganda</option>
                          <option value="&quot;@lu">Luiseno</option>
                          <option value="&quot;@lu">Lunda</option>
                          <option value="&quot;@lu">Luo (Kenya and Tanzania)</option>
                          <option value="&quot;@lu">Lushai</option>
                          <option value="&quot;@ma">Macedonian</option>
                          <option value="&quot;@ma">Madurese</option>
                          <option value="&quot;@ma">Magahi</option>
                          <option value="&quot;@ma">Marshallese</option>
                          <option value="&quot;@ma">Maithili</option>
                          <option value="&quot;@ma">Makasar</option>
                          <option value="&quot;@ma">Malayalam</option>
                          <option value="&quot;@ma">Mandingo</option>
                          <option value="&quot;@ma">Maori</option>
                          <option value="&quot;@ma">Austronesian languages</option>
                          <option value="&quot;@ma">Marathi</option>
                          <option value="&quot;@ma">Masai</option>
                          <option value="&quot;@ma">Malay</option>
                          <option value="&quot;@md">Moksha</option>
                          <option value="&quot;@md">Mandar</option>
                          <option value="&quot;@me">Mende</option>
                          <option value="&quot;@mg">Irish, Middle (900-1200)</option>
                          <option value="&quot;@mi">Mi'kmaq | Micmac</option>
                          <option value="&quot;@mi">Minangkabau</option>
                          <option value="&quot;@mi">Uncoded languages</option>
                          <option value="&quot;@mk">Macedonian</option>
                          <option value="&quot;@mk">Mon-Khmer languages</option>
                          <option value="&quot;@ml">Malagasy</option>
                          <option value="&quot;@ml">Maltese</option>
                          <option value="&quot;@mn">Manchu</option>
                          <option value="&quot;@mn">Manipuri</option>
                          <option value="&quot;@mn">Manobo languages</option>
                          <option value="&quot;@mo">Mohawk</option>
                          <option value="&quot;@mo">Mongolian</option>
                          <option value="&quot;@mo">Mossi</option>
                          <option value="&quot;@mr">Maori</option>
                          <option value="&quot;@ms">Malay</option>
                          <option value="&quot;@mu">Multiple languages</option>
                          <option value="&quot;@mu">Munda languages</option>
                          <option value="&quot;@mu">Creek</option>
                          <option value="&quot;@mw">Mirandese</option>
                          <option value="&quot;@mw">Marwari</option>
                          <option value="&quot;@my">Burmese</option>
                          <option value="&quot;@my">Mayan languages</option>
                          <option value="&quot;@my">Erzya</option>
                          <option value="&quot;@na">Nahuatl languages</option>
                          <option value="&quot;@na">North American Indian languages</option>
                          <option value="&quot;@na">Neapolitan</option>
                          <option value="&quot;@na">Nauru</option>
                          <option value="&quot;@na">Navajo | Navaho</option>
                          <option value="&quot;@nb">Ndebele, South | South Ndebele</option>
                          <option value="&quot;@nd">Ndebele, North | North Ndebele</option>
                          <option value="&quot;@nd">Ndonga</option>
                          <option value="&quot;@nd">Low German | Low Saxon | German, Low | Saxon, Low</option>
                          <option value="&quot;@ne">Nepali</option>
                          <option value="&quot;@ne">Nepal Bhasa | Newari</option>
                          <option value="&quot;@ni">Nias</option>
                          <option value="&quot;@ni">Niger-Kordofanian languages</option>
                          <option value="&quot;@ni">Niuean</option>
                          <option value="&quot;@nl">Dutch | Flemish</option>
                          <option value="&quot;@nn">Norwegian Nynorsk | Nynorsk, Norwegian</option>
                          <option value="&quot;@no">Bokmål, Norwegian | Norwegian Bokmål</option>
                          <option value="&quot;@no">Nogai</option>
                          <option value="&quot;@no">Norse, Old</option>
                          <option value="&quot;@no">Norwegian</option>
                          <option value="&quot;@nq">N'Ko</option>
                          <option value="&quot;@ns">Pedi | Sepedi | Northern Sotho</option>
                          <option value="&quot;@nu">Nubian languages</option>
                          <option value="&quot;@nw">Classical Newari | Old Newari | Classical Nepal Bhasa</option>
                          <option value="&quot;@ny">Chichewa | Chewa | Nyanja</option>
                          <option value="&quot;@ny">Nyamwezi</option>
                          <option value="&quot;@ny">Nyankole</option>
                          <option value="&quot;@ny">Nyoro</option>
                          <option value="&quot;@nz">Nzima</option>
                          <option value="&quot;@oc">Occitan (post 1500)</option>
                          <option value="&quot;@oj">Ojibwa</option>
                          <option value="&quot;@or">Oriya</option>
                          <option value="&quot;@or">Oromo</option>
                          <option value="&quot;@os">Osage</option>
                          <option value="&quot;@os">Ossetian | Ossetic</option>
                          <option value="&quot;@ot">Turkish, Ottoman (1500-1928)</option>
                          <option value="&quot;@ot">Otomian languages</option>
                          <option value="&quot;@pa">Papuan languages</option>
                          <option value="&quot;@pa">Pangasinan</option>
                          <option value="&quot;@pa">Pahlavi</option>
                          <option value="&quot;@pa">Pampanga | Kapampangan</option>
                          <option value="&quot;@pa">Panjabi | Punjabi</option>
                          <option value="&quot;@pa">Papiamento</option>
                          <option value="&quot;@pa">Palauan</option>
                          <option value="&quot;@pe">Persian, Old (ca.600-400 B.C.)</option>
                          <option value="&quot;@pe">Persian</option>
                          <option value="&quot;@ph">Philippine languages</option>
                          <option value="&quot;@ph">Phoenician</option>
                          <option value="&quot;@pl">Pali</option>
                          <option value="&quot;@po">Polish</option>
                          <option value="&quot;@po">Pohnpeian</option>
                          <option value="&quot;@po">Portuguese</option>
                          <option value="&quot;@pr">Prakrit languages</option>
                          <option value="&quot;@pr">Provençal, Old (to 1500) | Occitan, Old (to 1500)</option>
                          <option value="&quot;@pu">Pushto | Pashto</option>
                          <option value="&quot;@qt">Reserved for local use</option>
                          <option value="&quot;@qu">Quechua</option>
                          <option value="&quot;@ra">Rajasthani</option>
                          <option value="&quot;@ra">Rapanui</option>
                          <option value="&quot;@ra">Rarotongan | Cook Islands Maori</option>
                          <option value="&quot;@ro">Romance languages</option>
                          <option value="&quot;@ro">Romansh</option>
                          <option value="&quot;@ro">Romany</option>
                          <option value="&quot;@ro">Romanian | Moldavian | Moldovan</option>
                          <option value="&quot;@ru">Romanian | Moldavian | Moldovan</option>
                          <option value="&quot;@ru">Rundi</option>
                          <option value="&quot;@ru">Aromanian | Arumanian | Macedo-Romanian</option>
                          <option value="&quot;@ru">Russian</option>
                          <option value="&quot;@sa">Sandawe</option>
                          <option value="&quot;@sa">Sango</option>
                          <option value="&quot;@sa">Yakut</option>
                          <option value="&quot;@sa">South American Indian languages</option>
                          <option value="&quot;@sa">Salishan languages</option>
                          <option value="&quot;@sa">Samaritan Aramaic</option>
                          <option value="&quot;@sa">Sanskrit</option>
                          <option value="&quot;@sa">Sasak</option>
                          <option value="&quot;@sa">Santali</option>
                          <option value="&quot;@sc">Sicilian</option>
                          <option value="&quot;@sc">Scots</option>
                          <option value="&quot;@se">Selkup</option>
                          <option value="&quot;@se">Semitic languages</option>
                          <option value="&quot;@sg">Irish, Old (to 900)</option>
                          <option value="&quot;@sg">Sign Languages</option>
                          <option value="&quot;@sh">Shan</option>
                          <option value="&quot;@si">Sidamo</option>
                          <option value="&quot;@si">Sinhala | Sinhalese</option>
                          <option value="&quot;@si">Siouan languages</option>
                          <option value="&quot;@si">Sino-Tibetan languages</option>
                          <option value="&quot;@sl">Slavic languages</option>
                          <option value="&quot;@sl">Slovak</option>
                          <option value="&quot;@sl">Slovak</option>
                          <option value="&quot;@sl">Slovenian</option>
                          <option value="&quot;@sm">Southern Sami</option>
                          <option value="&quot;@sm">Northern Sami</option>
                          <option value="&quot;@sm">Sami languages</option>
                          <option value="&quot;@sm">Lule Sami</option>
                          <option value="&quot;@sm">Inari Sami</option>
                          <option value="&quot;@sm">Samoan</option>
                          <option value="&quot;@sm">Skolt Sami</option>
                          <option value="&quot;@sn">Shona</option>
                          <option value="&quot;@sn">Sindhi</option>
                          <option value="&quot;@sn">Soninke</option>
                          <option value="&quot;@so">Sogdian</option>
                          <option value="&quot;@so">Somali</option>
                          <option value="&quot;@so">Songhai languages</option>
                          <option value="&quot;@so">Sotho, Southern</option>
                          <option value="&quot;@sp">Spanish | Castilian</option>
                          <option value="&quot;@/e">Spanish</option>
                          <option value="&quot;@sq">Albanian</option>
                          <option value="&quot;@sr">Sardinian</option>
                          <option value="&quot;@sr">Sranan Tongo</option>
                          <option value="&quot;@sr">Serbian</option>
                          <option value="&quot;@sr">Serer</option>
                          <option value="&quot;@ss">Nilo-Saharan languages</option>
                          <option value="&quot;@ss">Swati</option>
                          <option value="&quot;@su">Sukuma</option>
                          <option value="&quot;@su">Sundanese</option>
                          <option value="&quot;@su">Susu</option>
                          <option value="&quot;@su">Sumerian</option>
                          <option value="&quot;@sw">Swahili</option>
                          <option value="&quot;@sw">Swedish</option>
                          <option value="&quot;@sy">Classical Syriac</option>
                          <option value="&quot;@sy">Syriac</option>
                          <option value="&quot;@ta">Tahitian</option>
                          <option value="&quot;@ta">Tai languages</option>
                          <option value="&quot;@ta">Tamil</option>
                          <option value="&quot;@ta">Tatar</option>
                          <option value="&quot;@te">Telugu</option>
                          <option value="&quot;@te">Timne</option>
                          <option value="&quot;@te">Tereno</option>
                          <option value="&quot;@te">Tetum</option>
                          <option value="&quot;@tg">Tajik</option>
                          <option value="&quot;@tg">Tagalog</option>
                          <option value="&quot;@th">Thai</option>
                          <option value="&quot;@ti">Tibetan</option>
                          <option value="&quot;@ti">Tigre</option>
                          <option value="&quot;@ti">Tigrinya</option>
                          <option value="&quot;@ti">Tiv</option>
                          <option value="&quot;@tk">Tokelau</option>
                          <option value="&quot;@tl">Klingon | tlhIngan-Hol</option>
                          <option value="&quot;@tl">Tlingit</option>
                          <option value="&quot;@tm">Tamashek</option>
                          <option value="&quot;@to">Tonga (Nyasa)</option>
                          <option value="&quot;@to">Tonga (Tonga Islands)</option>
                          <option value="&quot;@tp">Tok Pisin</option>
                          <option value="&quot;@ts">Tsimshian</option>
                          <option value="&quot;@ts">Tswana</option>
                          <option value="&quot;@ts">Tsonga</option>
                          <option value="&quot;@tu">Turkmen</option>
                          <option value="&quot;@tu">Tumbuka</option>
                          <option value="&quot;@tu">Tupi languages</option>
                          <option value="&quot;@tu">Turkish</option>
                          <option value="&quot;@tu">Altaic languages</option>
                          <option value="&quot;@tv">Tuvalu</option>
                          <option value="&quot;@tw">Twi</option>
                          <option value="&quot;@ty">Tuvinian</option>
                          <option value="&quot;@ud">Udmurt</option>
                          <option value="&quot;@ug">Ugaritic</option>
                          <option value="&quot;@ui">Uighur | Uyghur</option>
                          <option value="&quot;@uk">Ukrainian</option>
                          <option value="&quot;@um">Umbundu</option>
                          <option value="&quot;@un">Undetermined</option>
                          <option value="&quot;@ur">Urdu</option>
                          <option value="&quot;@uz">Uzbek</option>
                          <option value="&quot;@va">Vai</option>
                          <option value="&quot;@ve">Venda</option>
                          <option value="&quot;@vi">Vietnamese</option>
                          <option value="&quot;@vo">Volapük</option>
                          <option value="&quot;@vo">Votic</option>
                          <option value="&quot;@wa">Wakashan languages</option>
                          <option value="&quot;@wa">Wolaitta | Wolaytta</option>
                          <option value="&quot;@wa">Waray</option>
                          <option value="&quot;@wa">Washo</option>
                          <option value="&quot;@we">Welsh</option>
                          <option value="&quot;@we">Sorbian languages</option>
                          <option value="&quot;@wl">Walloon</option>
                          <option value="&quot;@wo">Wolof</option>
                          <option value="&quot;@xa">Kalmyk | Oirat</option>
                          <option value="&quot;@xh">Xhosa</option>
                          <option value="&quot;@ya">Yao</option>
                          <option value="&quot;@ya">Yapese</option>
                          <option value="&quot;@yi">Yiddish</option>
                          <option value="&quot;@yo">Yoruba</option>
                          <option value="&quot;@yp">Yupik languages</option>
                          <option value="&quot;@za">Zapotec</option>
                          <option value="&quot;@zb">Blissymbols | Blissymbolics | Bliss</option>
                          <option value="&quot;@ze">Zenaga</option>
                          <option value="&quot;@zg">Standard Moroccan Tamazight</option>
                          <option value="&quot;@zh">Zhuang | Chuang</option>
                          <option value="&quot;@zh">Chinese</option>
                          <option value="&quot;@zn">Zande languages</option>
                          <option value="&quot;@zu">Zulu</option>
                          <option value="&quot;@zu">Zuni</option>
                          <option value="&quot;@zx">No linguistic content | Not applicable</option>
                          <option value="&quot;@zz">Zaza | Dimili | Dimli | Kirdki | Kirmanjki | Zazaki </option>              
              </select>
            </div>
             <span class="input-group-btn field-controls"><button type="button" class="btn btn-link remove"><span
                    class="glyphicon glyphicon-remove"></span><span class="controls-remove-text">Remove</span> <span
                    class="sr-only"> previous <span class="controls-field-name-text"> Abstract</span></span></button></span>
          </li>
    HTML
  end

  private

  # Although the 'index' parameter is not used in this implementation it is useful in an
  # an overridden version of this method, especially when the field is a complex object and
  # the override defines nested fields.
  def build_field_options(value, index)
    options = input_html_options.dup


    #options[:value] = value if options[:value].nil?
    if !value.blank?
      options[:value] = value
    elsif value.blank? and !options[:value].blank?
      options[:value] = options[:value]
    else
      options[:value] = value
    end


    if @rendered_first_element
      options[:id] = nil
      options[:required] = nil
    else
      options[:id] ||= input_dom_id
    end
    options[:class] ||= []
    options[:class] += ["#{input_dom_id} form-control multi-text-field"]
    options[:'aria-labelledby'] = label_id
    @rendered_first_element = true

    options
  end

  def build_field(value, index)
    options = build_field_options(value, index)
    if options.delete(:type) == 'textarea'.freeze
      @builder.text_area(attribute_name, options)
    elsif options[:class].include? 'integer-input' #[hyc-override] multivalue integers
      @builder.number_field(attribute_name, options)
    elsif options[:class].include? 'date-input' #[hyc-override] multivalue dates
      @builder.date_field(attribute_name, options)
    else
      @builder.text_field(attribute_name, options)
    end
  end

  def label_id
    input_dom_id + '_label'
  end

  def input_dom_id
    input_html_options[:id] || "#{object_name}_#{attribute_name}"
  end

  def collection
    @collection ||= begin
      val = object.send(attribute_name)
      col = val.respond_to?(:to_ary) ? val.to_ary : val
      col.reject { |valuex| valuex.to_s.strip.blank? } + ['']
    end
  end

  def multiple?; true; end
end
