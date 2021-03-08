local noobIdentity = 3
local invisCountdown = 0
local invisOn = false
local curName = nil
local endPos = nil

function noobifyInit()
    Bind.create("specialTwo=true up=true down=false left=false right=false shift=false",noobOn,false)
    Bind.create("specialTwo=true up=true down=false left=false right=false shift=true",noobOnNinja,false)
    Bind.create("specialTwo=true up=false down=true left=false right=false",noobOff,false)
end

function noobifyUpdate(args)
    invisCountdown = math.max(invisCountdown - 1,0)
    
    if invisOn then
        dll.setName("")
        if invisCountdown == 0 then
            invisOn = false
            tech.setParentHidden(false)
            dll.setName(curName)
            curName = nil
            mcontroller.setPosition(endPos)
            endPos = nil
        end
    end
end

function noobifyUninit()
    currentIdentity = 1
    tech.setParentHidden(false)
end

function noobOnNinja()
    noobOn()

    local actions = {}
    local maxParticleTime = 1/3
    local numParticles = 40
    for i = 1, numParticles do
        table.insert(actions,{
            action = "particle",
            ["repeat"] = false,
            time = (i-1)/(numParticles-1) * maxParticleTime,
            specification = {
                type = "textured",
                image = "/cinematics/glitters.png?saturation=-100",
                timeToLive = 1/3 + 1/4,
                size = 0.05,
                destructionTime = 1,
                initialVelocity = {0,-0.5},
                finalVelocity = {0,-0.5},
                destructionAction = "shrink",
                variance = {
                    initialVelocity = {0,0.5},
                    finalVelocity = {0,-0.5},
                    rotation = 180,
                    position = {2,2}
                }
            }
        })
    end
    world.spawnProjectile("boltguide", mcontroller.position(), entity.id(), {0, 0}, false, {
        damageType = "NoDamage",
        processing = "?setcolor=000000?replace;000000=ffffff00",
        movementSettings = {
            collisionPoly = jarray()
        },
        timeToLive = 3,
        actionOnReap = jarray(),
        periodicActions = actions
    })
    local dirs = {-1,1}
    while endPos == nil do
        local testPos = vec2.add(mcontroller.position(),{(math.random()*10+10)*dirs[math.random(1,2)],5})
        local collisionPos = world.lineCollision(testPos,vec2.add(testPos,{0,-35})) or testPos
        endPos = world.resolvePolyCollision(mcontroller.collisionPoly(),collisionPos,5)
    end
    tech.setParentHidden(true)
    invisCountdown = 30
    invisOn = true
    curName = identityList[noobIdentity].name
end

function noobOn()
    currentIdentity = noobIdentity
    setNoobPreset()
    setIdentity(noobIdentity)
end

function noobOff()
    currentIdentity = 1
end

function setNoobPreset()
    local speciesList = {"apex","avian","floran","glitch","human","hylotl","novakid"}
    local species = speciesList[math.random(1,#speciesList)]
    local speciesConfig = root.assetJson("/species/" .. species .. ".species")
    
    local newIdentity = identityList[noobIdentity]
    local genderNum = math.random(1,#speciesConfig.genders)
    local genderConfig = speciesConfig.genders[genderNum]
    newIdentity.gender = genderConfig.name
    newIdentity.hairGroup = genderConfig.hairGroup or "hair"
    newIdentity.hairType = genderConfig.hair[math.random(1,#genderConfig.hair)]
    newIdentity.facialHairGroup = genderConfig.facialHairGroup
    if #genderConfig.facialHair ~= 0 then
        newIdentity.facialHairType = genderConfig.facialHair[math.random(1,#genderConfig.facialHair)]
    else
        newIdentity.facialHairType = ""
    end
    newIdentity.facialMaskGroup = genderConfig.facialMaskGroup
    if #genderConfig.facialMask ~= 0 then
        newIdentity.facialMaskType = genderConfig.facialMask[math.random(1,#genderConfig.facialMask)]
    else
        newIdentity.facialMaskType = ""
    end

    local bodyColor = speciesConfig.bodyColor[math.random(1,#speciesConfig.bodyColor)]
    local bodyDirectives = "?replace"
    for k, v in pairs(bodyColor) do
        bodyDirectives = bodyDirectives .. ";" .. k .. "=" .. v
    end
    local undyColor = speciesConfig.undyColor[math.random(1,#speciesConfig.undyColor)]
    local undyDirectives = "?replace"
    if undyColor == "" then
        undyDirectives = ""
    else
        for k, v in pairs(undyColor) do
            undyDirectives = undyDirectives .. ";" .. k .. "=" .. v
        end
    end
    local hairColor = speciesConfig.hairColor[math.random(1,#speciesConfig.hairColor)]
    local hairDirectives = "?replace"
    if hairColor == "" then
        hairDirectives = ""
    else
        for k, v in pairs(hairColor) do
            hairDirectives = hairDirectives .. ";" .. k .. "=" .. v
        end
    end

    newIdentity.bodyDirectives = bodyDirectives .. undyDirectives
    newIdentity.hairDirectives = bodyDirectives .. hairDirectives
    newIdentity.facialHairDirectives = newIdentity.hairDirectives

    if math.random(1,6) == 1 then -- 1 in 6 chance of having tier 1 armor, to look more noob
        newIdentity.clothes.chestCosmetic = {count=1,name=species.."tier1chest"}
        newIdentity.clothes.legsCosmetic = {count=1,name=species.."tier1pants"}
    else
        local shirt = genderConfig.shirt[math.random(1,#genderConfig.shirt)]
        newIdentity.clothes.chestCosmetic = {parameters={colorIndex=math.random(0,11)},name=shirt,count=1}
        local pants = genderConfig.pants[math.random(1,#genderConfig.pants)]
        newIdentity.clothes.legsCosmetic = {parameters={colorIndex=math.random(0,11)},name=pants,count=1}
    end

    if math.random(1,5) == 1 then
        newIdentity.clothes.backCosmetic = {count=1,name="raggedprotectoratecape"}
    else
        newIdentity.clothes.backCosmetic = "none"
    end
    if math.random(1,4) == 1 then -- 1 in 4 chance of having tier 1 armor, to look more noob
        newIdentity.clothes.headCosmetic = {count=1,name=species.."tier1head"}
    elseif math.random(1,5) == 1 then
        newIdentity.clothes.headCosmetic = {count=1,name="protectorateflowerhead"}
    else
        newIdentity.clothes.headCosmetic = "none"
    end

    newIdentity.species = species

    local humanoidConfig = root.assetJson("/humanoid.config")
    local newPersonality = humanoidConfig.personalities[math.random(1,#humanoidConfig.personalities)]
    newIdentity.personalityIdle = newPersonality[1]
    newIdentity.personalityArmIdle = newPersonality[2]
    newIdentity.personalityHeadOffset = newPersonality[3]
    newIdentity.personalityArmOffset = newPersonality[4]

    names = {
        apex = {{"Abram","Afanasy","Albert","Alexander","Alexei","Anatoly","Andrei","Anton","Arkady","Arseny","Artur","Artyom","Bogdan","Boris","Daniil","David","Denis","Dmitry","Eduard","Erik","Evgeny","Garry","Gavriil","Gennady","Georgy","Gerasim","German","Gleb","Grigory","Igor","Ilia","Illarion","Immanuil","Ivan","Kirill","Konstantin","Leo","Leonid","Lev","Makar","Marat","Mark","Matvei","Maxim","Mikhail","Nestor","Nikita","Nikolay","Oleg","Pavel","Peter","Pyotr","Robert","Rodion","Roman","Rostislav","Ruslan","Semyon","Sergei","Spartak","Stanislav","Stepan","Taras","Timofei","Timur","Trofim","Vadim","Valentin","Valery","Vasily","Veniamin","Viktor","Vitaly","Vlad","Vladimir","Vladislav","Vsevolod","Vyacheslav","Yakov","Yaroslav","Yefim","Yegor","Yulian","Yury","Zakhar"},{"Albina","Alexandra","Alina","Alisa","Alla","Alyona","Anastasiya","Anfisa","Anna","Antonina","Anzhelika","Darya","Diana","Dina","Dominika","Ekaterina","Elena","Elizaveta","Elvira","Emilia","Emma","Eva","Evgeniya","Faina","Fedosia","Florentina","Galina","Inessa","Inga","Inna","Irina","Iskra","Izabella","Izolda","Kapitolina","Klara","Klavdiya","Klementina","Kristina","Kseniya","Lada","Larisa","Lidiya","Liliya","Lubov","Lucya","Ludmila","Malvina","Margarita","Marina","Mariya","Marta","Maya","Nadezhda","Natalya","Nelly","Nika","Nina","Nonna","Oksana","Olesya","Olga","Polina","Rada","Raisa","Regina","Renata","Rozalina","Sofia","Svetlana","Taisia","Tamara","Tatyana","Ulyana","Valentina","Valeriya","Varvara","Vasilisa","Vera","Veronika","Viktoriya","Vladlena","Yana","Yaroslava","Yuliya","Zhanna","Zinaida","Zlata","Zoya"}},
        avian = {{"ACHCAUHTLI","AHUILIZTLI","AMOXTLI","ATL","CENTEHUA","CHALCHIUHTICUE","CHALCHIUITL","CHICAHUA","CHIMALLI","CHIPAHUA","CIHUATON","CIPACTLI","CITLALI","CITLALMINA","COATL","COAXOCH","COSZCATL","COYOTL","COZAMALOTL","CUALLI","CUAUHTÉMOC","CUETLACHTLI","CUETZPALLI","CUICATL","CUIXTLI","EHECATL","ELEUIA","ELOXOCHITL","ETALPALLI","EZTLI","HUEMAC","HUITZILIHUITL","HUITZILLI","ICCAUHTLI","ICHTACA","ICNOYOTL","IHUICATL","ILHICAMINA","ILHUITL","ITOTIA","ITZEL","ITZTLI","IUITL","IXCATZIN","IXCHEL","IXTLI","IZEL","MAHUIZOH","MALINALXOCHITL","MANAUIA","MATLAL","MATLALIHUITL","MAZATL","MECATL","MEZTLI","MICTLANTECUHTLI","MILINTICA","MIYAOAXOCHITL","MIZQUIXAUAL","MOMOZTLI","MOYOLEHUANI","NAHUATL","NAMACUIX","NECAHUAL","NECALLI","NECUAMETL","NELLI","NENETL","NEZAHUALCOYOTL","NEZAHUALPILLI","NOCHEHUATL","NOCHTLI","NOPALTZIN","NOXOCHICOZTLI","OHTLI","OLLIN","PAPAN","PATLI","QUAUHTLI","QUETZALCOATL","QUETZALXOCHITL","SACNITE","TEICUIH","TENOCH","TEOXIHUITL","TEPILTZIN","TEPIN","TEUICUI","TEYACAPAN","TEZCACOATL","TLACAELEL","TLACELEL","TLACHINOLLI","TLACO","TLACOEHUA","TLACOTL","TLALLI","TLALOC","TLANEXTIC","TLANEXTLI","TLAZOHTLALONI","TLAZOHTZIN","TLAZOPILLI","TLEXICTLI","TLILPOTONQUI","TOCHTLI","TOLTECATL","TONALNAN","TONAUAC","TOTOTL","UEMAN","UETZCAYOTL","XICOHTENCATL","XIHUITL","XILOXOCH","XIPIL","XIPILLI","XIUHCOATL","XIUHTONAL","XOCHICOTZIN","XOCHIPEPE","XOCHIPILLI","XOCHIQUETZAL","XOCHITL","XOCHIYOTL","XOCO","XOCOYOTL","YAOTL","YAYAUHQUI","YOLIHUANI","YOLOTLI","YOLOXOCHITL","YOLTZIN","YOLYAMANITZIN","ZELTZIN","ZIPACTONAL","ZOLIN","ZYANYA"},{"ACHCAUHTLI","AHUILIZTLI","AMOXTLI","ATL","CENTEHUA","CHALCHIUHTICUE","CHALCHIUITL","CHICAHUA","CHIMALLI","CHIPAHUA","CIHUATON","CIPACTLI","CITLALI","CITLALMINA","COATL","COAXOCH","COSZCATL","COYOTL","COZAMALOTL","CUALLI","CUAUHTÉMOC","CUETLACHTLI","CUETZPALLI","CUICATL","CUIXTLI","EHECATL","ELEUIA","ELOXOCHITL","ETALPALLI","EZTLI","HUEMAC","HUITZILIHUITL","HUITZILLI","ICCAUHTLI","ICHTACA","ICNOYOTL","IHUICATL","ILHICAMINA","ILHUITL","ITOTIA","ITZEL","ITZTLI","IUITL","IXCATZIN","IXCHEL","IXTLI","IZEL","MAHUIZOH","MALINALXOCHITL","MANAUIA","MATLAL","MATLALIHUITL","MAZATL","MECATL","MEZTLI","MICTLANTECUHTLI","MILINTICA","MIYAOAXOCHITL","MIZQUIXAUAL","MOMOZTLI","MOYOLEHUANI","NAHUATL","NAMACUIX","NECAHUAL","NECALLI","NECUAMETL","NELLI","NENETL","NEZAHUALCOYOTL","NEZAHUALPILLI","NOCHEHUATL","NOCHTLI","NOPALTZIN","NOXOCHICOZTLI","OHTLI","OLLIN","PAPAN","PATLI","QUAUHTLI","QUETZALCOATL","QUETZALXOCHITL","SACNITE","TEICUIH","TENOCH","TEOXIHUITL","TEPILTZIN","TEPIN","TEUICUI","TEYACAPAN","TEZCACOATL","TLACAELEL","TLACELEL","TLACHINOLLI","TLACO","TLACOEHUA","TLACOTL","TLALLI","TLALOC","TLANEXTIC","TLANEXTLI","TLAZOHTLALONI","TLAZOHTZIN","TLAZOPILLI","TLEXICTLI","TLILPOTONQUI","TOCHTLI","TOLTECATL","TONALNAN","TONAUAC","TOTOTL","UEMAN","UETZCAYOTL","XICOHTENCATL","XIHUITL","XILOXOCH","XIPIL","XIPILLI","XIUHCOATL","XIUHTONAL","XOCHICOTZIN","XOCHIPEPE","XOCHIPILLI","XOCHIQUETZAL","XOCHITL","XOCHIYOTL","XOCO","XOCOYOTL","YAOTL","YAYAUHQUI","YOLIHUANI","YOLOTLI","YOLOXOCHITL","YOLTZIN","YOLYAMANITZIN","ZELTZIN","ZIPACTONAL","ZOLIN","ZYANYA"}},
        floran = {{"ABBA","ABEBEC","ABEBI","ABENA","ABRIHET","ABA","ABI","ACACIA","ACHAN","ADA","ADAMA","ADANECH","ADANNA","ADEOLA","ADETOUN","ADHIAMBO","ADINA","ADJOA","ADWOA","ADDO","ADOWA","AFAFA","AFIA","AFRA","AFUA","AFYA","AGBENYAGA","AINA","AISHA","AYISHA","ASHA","AJA","AJAMBOON","AKILAH","AKIM","AKOSUA","AKPENAMAWU","AKUA","ALAMOUT","ALITASH","ALITASH","AMA","AMACHI","AMANISHAKHETE","AMARA","AMBER","AMINA","AMINATA","AMINIA","ANAYA","ANNAKIYA","ANULIKA","ANYANGO","ARET","ARMANI","ARUSI","ASABI","ASHAKI","ASHIA","ASMINA","ASSAGGI","ASURA","ATSUKPI","AURORA","AYAN","AYANA","AYO","AZA","AZINZA","AZIZA","AZMERA","BAHATI","BALINDA","BATHSHEBA","BELA","BELLA","BETELIHE","BERHANE","BIBI","BINATA","BINTA","BUCHI","BUPE","CHANYA","CHICHA","CHIKU","CHINA","CHINAKA","CHINARA","CRISPINA","DADA","DALILA","DEKA","DELA","DESTA","DOLIE","EBIERE","EFFIWAT","EFIA","EFRA","ESHE","ESI","ESIANKIKI","ESINAM","FANA","FANTA","FATUMA","FAYOLA","FEMBAR","FOLA","FOWSIA","GOGO","GYAMFUA","GZIFA","HABIBA","HADIYA","HADIYAH","HALIMA","HALIMAH","HASANA","HASINA","HAWA","HOLA","IFEOMA","IMAN","ISMITTA","ISSA","IVEREM","IYANGURA","JAHA","JAINEBA","JAPERA","JIFUNZA","JUBA","JWAHIR","KADIJA","KHADIJA","KAMARIA","KAMBIRI","KANIKA","KATURA","KAYA","KENGI","KENYA","KESI","KESSIE","KHATITI","KIBIBI","KIFLE","KISSA","KOKO","KWESI","LAYLA","LAILA","LEYLA","LEILA","LETA","LEZA","LINDA","LINDIWE","LISHAN","LOIYAN","LULU","MAKDA","MAKEDA","MAKEMBA","MAKENA","MANDISA","MAPENZI","MPENZI","MARIAMA","MARJANI","MARWE","MASSASSI","MAWUNYAGA","MIHRET","MESERET","MISRAK","MONIFA","MUTHONI","NONI","NADIFA","NADRA","NADIRA","NAGESA","NAJJA","NAKI","NALIAKA","NANA","NANGILA","NAZI","NDILA","NEEMA","NEHANDA","NEHANDA","NEGASH","NIGESA","NINI","NISHAN","NJEMILE","NKECHI","NURU","OBAX","OLA","ONAEDO","ONI","RADHIYA","RAMATULAI","RAMLA","RASHIDA","RASHEEDA","RACHIDA","RAASHIDA","RAZIYA","REHEMA","RHAXMA","SAADA","SADIO","SAFIA","SAFIYA","SAFIYEH","SAFIYYAH","SAIDA","SALAMA","SALMA","SANURA","SARAN","SAUDA","SEBLE","SEKAI","SELA","SELAM","SELAMAWIT","SHANI","SHARUFA","SISAY","SITI","SRODA","TABIA","TAFUI","TANDRA","TANISHA","TANI","TARANA","TATU","TAWIA","TERU","TIRUNESH","TISA","TITI","TSEDEY","UCHENNA","ULU","URENNA","WAGAYE","WAMBUI","WAMBOI","WANGARI","WANYIKA","WUB","XETSA","XOLA","XOLANI","YESHI","ZAHINA","ZAHRA","ZAHARA","ZAINABU","ZAKIYA","ZALIKA","ZAUDITU","ZAWDITU","ZAWADI","ZEINAB","ZENA","ZINSA","ZOLA","ZUHURA","ZWENA","ZUWENA"},{"ABBA","ABEBEC","ABEBI","ABENA","ABRIHET","ABA","ABI","ACACIA","ACHAN","ADA","ADAMA","ADANECH","ADANNA","ADEOLA","ADETOUN","ADHIAMBO","ADINA","ADJOA","ADWOA","ADDO","ADOWA","AFAFA","AFIA","AFRA","AFUA","AFYA","AGBENYAGA","AINA","AISHA","AYISHA","ASHA","AJA","AJAMBOON","AKILAH","AKIM","AKOSUA","AKPENAMAWU","AKUA","ALAMOUT","ALITASH","ALITASH","AMA","AMACHI","AMANISHAKHETE","AMARA","AMBER","AMINA","AMINATA","AMINIA","ANAYA","ANNAKIYA","ANULIKA","ANYANGO","ARET","ARMANI","ARUSI","ASABI","ASHAKI","ASHIA","ASMINA","ASSAGGI","ASURA","ATSUKPI","AURORA","AYAN","AYANA","AYO","AZA","AZINZA","AZIZA","AZMERA","BAHATI","BALINDA","BATHSHEBA","BELA","BELLA","BETELIHE","BERHANE","BIBI","BINATA","BINTA","BUCHI","BUPE","CHANYA","CHICHA","CHIKU","CHINA","CHINAKA","CHINARA","CRISPINA","DADA","DALILA","DEKA","DELA","DESTA","DOLIE","EBIERE","EFFIWAT","EFIA","EFRA","ESHE","ESI","ESIANKIKI","ESINAM","FANA","FANTA","FATUMA","FAYOLA","FEMBAR","FOLA","FOWSIA","GOGO","GYAMFUA","GZIFA","HABIBA","HADIYA","HADIYAH","HALIMA","HALIMAH","HASANA","HASINA","HAWA","HOLA","IFEOMA","IMAN","ISMITTA","ISSA","IVEREM","IYANGURA","JAHA","JAINEBA","JAPERA","JIFUNZA","JUBA","JWAHIR","KADIJA","KHADIJA","KAMARIA","KAMBIRI","KANIKA","KATURA","KAYA","KENGI","KENYA","KESI","KESSIE","KHATITI","KIBIBI","KIFLE","KISSA","KOKO","KWESI","LAYLA","LAILA","LEYLA","LEILA","LETA","LEZA","LINDA","LINDIWE","LISHAN","LOIYAN","LULU","MAKDA","MAKEDA","MAKEMBA","MAKENA","MANDISA","MAPENZI","MPENZI","MARIAMA","MARJANI","MARWE","MASSASSI","MAWUNYAGA","MIHRET","MESERET","MISRAK","MONIFA","MUTHONI","NONI","NADIFA","NADRA","NADIRA","NAGESA","NAJJA","NAKI","NALIAKA","NANA","NANGILA","NAZI","NDILA","NEEMA","NEHANDA","NEHANDA","NEGASH","NIGESA","NINI","NISHAN","NJEMILE","NKECHI","NURU","OBAX","OLA","ONAEDO","ONI","RADHIYA","RAMATULAI","RAMLA","RASHIDA","RASHEEDA","RACHIDA","RAASHIDA","RAZIYA","REHEMA","RHAXMA","SAADA","SADIO","SAFIA","SAFIYA","SAFIYEH","SAFIYYAH","SAIDA","SALAMA","SALMA","SANURA","SARAN","SAUDA","SEBLE","SEKAI","SELA","SELAM","SELAMAWIT","SHANI","SHARUFA","SISAY","SITI","SRODA","TABIA","TAFUI","TANDRA","TANISHA","TANI","TARANA","TATU","TAWIA","TERU","TIRUNESH","TISA","TITI","TSEDEY","UCHENNA","ULU","URENNA","WAGAYE","WAMBUI","WAMBOI","WANGARI","WANYIKA","WUB","XETSA","XOLA","XOLANI","YESHI","ZAHINA","ZAHRA","ZAHARA","ZAINABU","ZAKIYA","ZALIKA","ZAUDITU","ZAWDITU","ZAWADI","ZEINAB","ZENA","ZINSA","ZOLA","ZUHURA","ZWENA","ZUWENA"}},
        glitch = {{{"Stark","Brass","Iron","Rend","Cleave","Arrow","Cog","Siege","Long","Stone","Turn","Brave","Gold","Storm","Farm","Star","Free","Wind","Swift","Thunder","Jet","Spark","Bronze","Night","Rust"},{"bolt","mate","heart","chain","oak","quill","march","spear","blade","knave","lord","watch","shield","pike","wall","rake","finger","latch","mail","lance","wire","nail","foot","hand"}},{{"Song","Sing","Iron","Hope","Star","Arrow","Silver","Charm","Siege","Long","Shine","Turn","Brave","Gold","Storm","Farm","Star","Free","Wind","Swift","Moon","Wing","Spark","Night","Sunny","Bright"},{"bolt","mate","heart","chain","oak","quill","march","spear","blade","knave","lord","watch","shield","pike","wall","rake","finger","latch","mail","lance","wire","nail","foot","flower"}}},
        human = {{"Adam", "Alex", "Alexis", "Andre", "Amal", "Amos", "Anton", "Arjun", "Ash", "Ashton", "Asier", "Benny", "Billy", "Boyan", "Bran", "Bruno", "Byron", "Cameron", "Carl", "Carlos", "Carson",  "Casper", "Cassidy", "Chao", "Charlie", "Clancy", "Clarke", "Claude", "Clay", "Cody", "Coltrane", "Conan", "Corey", "Cosmo", "Cyrus", "Dave", "Dean", "Declan", "Derek", "Desmond", "Devin", "Djuro", "Dom", "Draven", "Edwin", "Einar", "Elvis", "Emil", "Enzo", "Eoin", "Fabian", "Faris", "Felix", "Fife", "Finn", "Floyd", "Francis", "Fred", "George", "Gilroy", "Gus", "Guy", "Hasim", "Hayden", "Hector", "Heike", "Hill", "Huey", "Iker", "Inigo", "Irving", "Isaac", "Issy", "Ivo", "Izem", "Jabir", "Jaden", "Jamie", "James", "Jan", "Javier", "Jay", "Jim", "Joe", "José", "Joel", "Jemmy", "Jesper", "Jesse", "Jin", "Juan", "Jude", "Julian", "Keane", "Kim", "Kirk", "Kit", "Lane", "Lee", "Leon", "Leo", "Liu", "Livio", "Lucian", "Ludvig", "Luigi", "Luis", "Lukas", "Mac", "Magnus", "Manolo", "Marc", "Marcel", "Mario", "Martin", "Matt", "Max", "Melville", "Micah", "Mick", "Ming", "Miron", "Morgan", "Marley", "Monty", "Nevada", "Niall", "Nick", "Ninos", "Noel", "Nolan", "Norris", "Oran", "Orion", "Oswin", "Owen", "Paco", "Parker", "Pau", "Payton", "Perry", "Pete", "Prince", "Quinn", "Ralph", "Ray", "Reed", "Ren", "Rigel", "Robin", "Roc", "Ronald", "Rory", "Samir", "Sarge", "Sarkis", "Scout", "Seb", "Sherman", "Shui", "Skip", "Skipper", "Sonny", "Stelian","Sten", "Stephen", "Sterling", "Steve", "Sweeney", "Theo", "Toby", "Tom", "Tyler", "Vaughn", "Vincent", "Wes", "Wesley", "William", "Wulf", "Xuan", "Yam", "Yanko", "Yannick", "Yang", "Yrian", "Zac", "Zhi", "Zoran","Addison", "Alex", "Alexis", "Aleksei", "Andre", "Angel", "Ashley", "Ashton", "Bailey", "Billy", "Blair", "Byron", "Caden", "Cameron", "Carmen", "Carmine", "Carson", "Cassidy", "Chen", "Charlie", "Chiaki", "Cody", "Corey", "Dakota", "Dallas", "Delaney", "Devon", "Ellery", "Emerson", "Fabian", "Francis", "Georgi", "Hadley", "Harley", "Hayden", "Ira", "Jaden", "Jamie", "Jan", "Jesse", "Jin", "Jude", "Julian", "Kadin", "Kelsey", "Kiley", "Lane", "Lee", "Lindsay", "Lonnie", "Liu", "Lucian", "Mallory", "Montana", "Morgan", "Marley", "Naoko", "Nevada", "Noel", "Orion", "Oleg", "Paris", "Parker", "Payton", "Perry", "Quinn", "Reed", "Rene", "Robin", "Scout", "Shay", "Shelby", "Sonny", "Skylar", "Sunny", "Sydney", "Stormy", "Taylor", "Tory", "Tyler", "Ulf", "Wesley", "Wynne", "Yang", "Yi", "Yuri", "Yury"},{"Abi", "Addison", "Adria", "Agnes", "Alex", "Alexis", "Alice", "Alysia", "Amity", "Anka", "Anne", "Annice", "Angel", "Annie", "Ariel", "Ashley", "Astra", "Bailey", "Bianka", "Beatriz", "Bee", "Betty", "Blair", "Bobbie", "Carina", "Carla", "Carmen", "Carmine", "Cassie", "Celeste", "Chelle", "Chiara", "Chrisjen", "Cindy", "Daisy", "Dakota", "Dallas", "Daphne", "Darija", "Dawn", "Delia", "Demi", "Devon", "Donna", "Doris", "Ecrin", "Elaine", "Elara", "Ellen", "Emilia", "Emma", "Elsa", "Erin", "Estelle", "Ethna", "Eva", "Evren", "Freya", "Frankie", "Gala", "Gem", "Georgi", "Gerry", "Gina", "Goldie", "Greta", "Gul", "Hadley", "Harriet", "Harley", "Hayley", "Hiba", "Hilda", "Ibbie", "Ida", "Idril", "Inga", "Ira", "Iris", "Irma", "Isolde", "Jeong", "Jaki", "Jantine", "Jazmin", "Jessie", "Jodi", "June", "Jude", "Karin", "Kata", "Kelly", "Kelsey", "Kiki", "Kleio", "Laurie", "Layla", "Leah", "Lenna", "Lili", "Linda", "Lindsay", "Linn", "Lonnie", "Lorene", "Lorette", "Lorna", "Lucy", "Luna", "Lyra", "Malina", "Mallory", "Mara", "Margo", "Mariel", "Marisa", "Maya", "Maytal", "Mercia","Mette", "Mila", "Milka", "Mimi", "Mina", "Mira", "Misty", "Moira", "Molly", "Montana", "Morgan", "Nalani", "Nasim", "Nell", "Neske", "Neva", "Nevada", "Nona", "Norah", "Olga", "Paris", "Payton", "Peony", "Pia", "Quinn", "Rakel", "Reed", "Remi", "Rene", "Rima", "Rita", "Robin", "Rosa", "Rosie", "Rue", "Saga", "Saige", "Samara", "Sara", "Scout", "Selma", "Shana", "Shay", "Sigrun", "Sita", "Shelby", "Sitara", "Skylar", "Sunny", "Suri", "Suzette", "Sydney", "Star", "Stormy", "Tania", "Taylor", "Tegan", "Telma", "Thyra", "Ursa", "Vera", "Vivi", "Vardah", "Wanda", "Wendy", "Yulia", "Zaray", "Ziv", "Zlata", "Zoe", "Zora","Addison", "Alex", "Alexis", "Aleksei", "Andre", "Angel", "Ashley", "Ashton", "Bailey", "Billy", "Blair", "Byron", "Caden", "Cameron", "Carmen", "Carmine", "Carson", "Cassidy", "Chen", "Charlie", "Chiaki", "Cody", "Corey", "Dakota", "Dallas", "Delaney", "Devon", "Ellery", "Emerson", "Fabian", "Francis", "Georgi", "Hadley", "Harley", "Hayden", "Ira", "Jaden", "Jamie", "Jan", "Jesse", "Jin", "Jude", "Julian", "Kadin", "Kelsey", "Kiley", "Lane", "Lee", "Lindsay", "Lonnie", "Liu", "Lucian", "Mallory", "Montana", "Morgan", "Marley", "Naoko", "Nevada", "Noel", "Orion", "Oleg", "Paris", "Parker", "Payton", "Perry", "Quinn", "Reed", "Rene", "Robin", "Scout", "Shay", "Shelby", "Sonny", "Skylar", "Sunny", "Sydney", "Stormy", "Taylor", "Tory", "Tyler", "Ulf", "Wesley", "Wynne", "Yang", "Yi", "Yuri", "Yury"}},
        hylotl = {{"AKIO","AKIRA","AOI","ARATA","AYUMU","DAICHI","DAIKI","DAISUKE","GORO","GOROU","HACHIRO","HACHIROU","HARU","HARUKI","HARUTO","HAYATO","HIBIKI","HIDEAKI","HIDEKI","HIDEYOSHI","HIKARU","HINATA","HIRAKU","HIROSHI","HIROTO","ICHIRO","ICHIROU","ISAMU","ITSUKI","JIRO","JIROU","JURO","JUROU","KAEDE","KAITO","KAORU","KATASHI","KATSU","KATSUO","KATSURO","KATSUROU","KAZUKI","KAZUO","KEN","KENICHI","KENJI","KENSHIN","KENTA","KICHIRO","KICHIROU","KIYOSHI","KOHAKU","KOUKI","KOUTA","KURO","KUROU","KYO","KYOU","MAKOTO","MASARU","MICHI","MINORU","NAOKI","NAOMI","NOBORU","NOBU","NOBURU","NOBUYUKI","NORI","OSAMU","REN","RIKU","RIKUTO","ROKURO","ROKUROU","RYO","RYOICHI","RYOTA","RYOU","RYOUICHI","RYOUTA","RYUU","RYUUNOSUKE","SABURO","SABUROU","SHICHIRO","SHICHIROU","SHIN","SHINOBU","SHIORI","SHIRO","SHIROU","SHO","SHOTA","SHOU","SHOUTA","SHUN","SORA","SOTA","SOUMA","SOUTA","SUSUMU","TAICHI","TAIKI","TAKAHIRO","TAKASHI","TAKEHIKO","TAKESHI","TAKUMA","TAKUMI","TARO","TAROU","TSUBASA","YAMATO","YASU","YORI","YOSHI","YOSHIRO","YOSHIROU","YOUTA","YUKI","YUU","YUUDAI","YUUKI","YUUTA","YUUTO"},{"AI","AIKO","AIMI","AINA","AIRI","AKANE","AKEMI","AKI","AKIKO","AKIRA","AMI","AOI","ASUKA","ATSUKO","AYA","AYAKA","AYAKO","AYAME","AYANE","AYANO","CHIKA","CHIKAKO","CHINATSU","CHIYO","CHIYOKO","CHO","CHOU","CHOUKO","EMI","ETSUKO","HANA","HANAE","HANAKO","HARU","HARUKA","HARUKO","HARUNA","HIKARI","HIKARU","HINA","HINATA","HIROKO","HITOMI","HONOKA","HOSHI","HOSHIKO","HOTARU","IZUMI","JUNKO","KAEDE","KANON","KAORI","KAORU","KASUMI","KAZUE","KAZUKO","KEIKO","KIKU","KIMIKO","KIYOKO","KOHAKU","KOHARU","KOKORO","KOTONE","KUMIKO","KYO","KYOU","MAI","MAKOTO","MAMI","MANAMI","MAO","MARIKO","MASAMI","MASUYO","MAYU","MEGUMI","MEI","MICHI","MICHIKO","MIDORI","MIKA","MIKI","MIKU","MINAKO","MINATO","MIO","MISAKI","MITSUKO","MIU","MIYAKO","MIYU","MIZUKI","MOE","MOMOKA","MOMOKO","MORIKO","NANA","NANAMI","NAOKO","NAOMI","NATSUKI","NATSUKO","NATSUMI","NOA","NORIKO","RAN","REI","REN","RIKO","RIN","RINA","RIO","SACHIKO","SAKI","SAKURA","SAKURAKO","SATOMI","SAYURI","SETSUKO","SHINJU","SHINOBU","SHIORI","SHIZUKA","SHUN","SORA","SUMIKO","SUZU","SUZUME","TAKAKO","TAKARA","TAMIKO","TOMIKO","TOMOKO","TOMOMI","TSUBAKI","TSUBAME","TSUBASA","TSUKIKO","UME","UMEKO","WAKANA","YASU","YOKO","YOSHI","YOSHIKO","YOUKO","YUA","YUI","YUINA","YUKI","YUKIKO","YUKO","YUMI","YUMIKO","YURI","YUU","YUUKA","YUUKI","YUUKO","YUUNA","YUZUKI"}},
        novakid = {{"Ace","Acro","Acryl","Ammo","Amyl","Aqu","Argon","Axus","Azen","Azure","Badde","Bail","Benze","Benzy","Beryl","Billy","Blaz","Blue","Boston","Bronco","Buck","Bullet","Butane","Butch","Butyl","Byrd","Carbo","Cerise","Clint","Clem","Cobalt","Country","Cetus","Chloro","Chrome","Corvus","Crimson","Curie","Cyan","Cylo","Dace","Dandy","Dash","Decane","Desert","Dex","Dice","Ditch","Diethyl","Dioxie","Dioxol","Dodeca","Domino","Dowan","Droe","Dusty","Dyme","Epich","Eryx","Ethane","Ethoxy","Ethyl","Farady","Flint","Freon","Fuel","Furan","Furf","Gibbs","Goode","Green","Gun","Gutter","Helium","Heptan","Hexan","Hexen","Hydro","Ion","Indigo","Isobu","Jane","Jesse","Jet","Kadi","Kero","Kid","Lacto","Lane","Lasso","Lead","Lefty","Leo","Lex","Libra","Luca","Lucky","Lumen","Lynx","Lyra","Magie","Marshall","Merca","Metha","Methan","Methox","Methyl","Milli","Minera","Montana","Naptha","Neon","Nitric","Nitro","Nonane","Octane","Octyl","Orio","Oxy","Pentan","Perch","Pers","Pete","Pheno","Phenyl","Pinen","Pistol","Propane","Propyl","Quark","Quarren","Randy","Raider","Raven","Razor","Red","Ringo","Ruby","Rush","Ryder","Saddle","Sawyer","Scarlet","Scout","Seth","Shade","Silver","Smokey","Sonny","Spike","Styre","Slang","Target","Teal","Tert","Tesla","Tetra","Topper","Trigger","Trix","Ursa","Varni","Vela","Vinyl","Virgo","Ward","Warren","Wayne","Whip","Wild","Xylene","Xenon","Zane","Zeke","Zinc","Zolan"},{"Ace","Acro","Acryl","Ammo","Amyl","Aqu","Argon","Axus","Azen","Azure","Badde","Bail","Benze","Benzy","Beryl","Billy","Blaz","Blue","Boston","Bronco","Buck","Bullet","Butane","Butch","Butyl","Byrd","Carbo","Cerise","Clint","Clem","Cobalt","Country","Cetus","Chloro","Chrome","Corvus","Crimson","Curie","Cyan","Cylo","Dace","Dandy","Dash","Decane","Desert","Dex","Dice","Ditch","Diethyl","Dioxie","Dioxol","Dodeca","Domino","Dowan","Droe","Dusty","Dyme","Epich","Eryx","Ethane","Ethoxy","Ethyl","Farady","Flint","Freon","Fuel","Furan","Furf","Gibbs","Goode","Green","Gun","Gutter","Helium","Heptan","Hexan","Hexen","Hydro","Ion","Indigo","Isobu","Jane","Jesse","Jet","Kadi","Kero","Kid","Lacto","Lane","Lasso","Lead","Lefty","Leo","Lex","Libra","Luca","Lucky","Lumen","Lynx","Lyra","Magie","Marshall","Merca","Metha","Methan","Methox","Methyl","Milli","Minera","Montana","Naptha","Neon","Nitric","Nitro","Nonane","Octane","Octyl","Orio","Oxy","Pentan","Perch","Pers","Pete","Pheno","Phenyl","Pinen","Pistol","Propane","Propyl","Quark","Quarren","Randy","Raider","Raven","Razor","Red","Ringo","Ruby","Rush","Ryder","Saddle","Sawyer","Scarlet","Scout","Seth","Shade","Silver","Smokey","Sonny","Spike","Styre","Slang","Target","Teal","Tert","Tesla","Tetra","Topper","Trigger","Trix","Ursa","Varni","Vela","Vinyl","Virgo","Ward","Warren","Wayne","Whip","Wild","Xylene","Xenon","Zane","Zeke","Zinc","Zolan"}}
    }
    local name = ""
    if type(names[species][genderNum][1]) == "table" then -- glitch, prefixes and suffixes
        name = names[species][genderNum][1][math.random(1,#names[species][genderNum][1])] .. names[species][genderNum][2][math.random(1,#names[species][genderNum][2])]
    else
        name = names[species][genderNum][math.random(1,#names[species][genderNum])]
    end
    newIdentity.name = name:sub(1,1):upper() .. name:sub(2):lower() -- normalize capitalization

    identityList[noobIdentity] = newIdentity
end