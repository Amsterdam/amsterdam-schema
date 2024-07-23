import json

# Het pad naar je JSON-bestand op je computer
#input_bestandspad = "C:\\Users\\kesgin002\\Documenten\\github\\schema\\schemas\\amsterdam-schema\\datasets\\huishoudelijkafval\\bijplaatsingen\\v2.3.0.json"
#output_bestandspad = "C:\\Users\\kesgin002\\Documenten\\github\\schema\\schemas\\amsterdam-schema\\datasets\\huishoudelijkafval\\bijplaatsingen\\v2.4.0.json"  # Het pad naar het nieuwe JSON-bestand

input_bestandspad = "C:\\Users\\kesgin002\\OneDrive - Gemeente Amsterdam\\Documenten\\git\\schemas\\amsterdam-schema\\datasets\\huishoudelijkafval\\bijplaatsingen\\v2.3.0.json"
input_bestandspad = "C:\\Users\\kesgin002\\OneDrive - Gemeente Amsterdam\\Documenten\\git\\schemas\\amsterdam-schema\\datasets\\huishoudelijkafval\\bijplaatsingen\\v2.4.0.json"

# Laden van het JSON-bestand
with open(input_bestandspad, "r") as bestand:
    schema = json.load(bestand)

# Functie om de naam van het eigenschap als waarde van het "title" attribuut toe te wijzen, met spaties en elke nieuwe
# woorden die beginnen met een hoofdletter
def add_title_from_parent(schema):
    def process_properties(properties):
        for prop_name, prop in properties.items():
            if 'description' in prop:
                # Voeg spaties toe tussen woorden en zet elke nieuwe woord met een hoofdletter
                title = ''.join(' ' + char if char.isupper() else char for char in prop_name).strip().capitalize()
                # Gebruik de aangepaste titel als waarde voor het "title" attribuut
                prop['title'] = title
            if prop.get('type') == 'object' and 'properties' in prop:
                # Ga dieper in de hiërarchie als het een object is met properties
                process_properties(prop['properties'])
            if prop.get('type') == 'array' and 'items' in prop:
                # Als het een array is, verwerk de items ervan
                items = prop['items']
                if 'properties' in items:
                    process_properties(items['properties'])

    process_properties(schema['schema']['properties'])

    return schema

# Toevoegen van "title" attribuut aan alle attributen met een "description" attribuut, waarbij de naam van het eigenschap
# met spaties en elke nieuwe woorden die beginnen met een hoofdletter wordt gebruikt als waarde voor het "title" attribuut
schema_with_title = add_title_from_parent(schema)

# Schrijf het bijgewerkte JSON-schema naar een nieuw bestand
with open(output_bestandspad, "w") as output_bestand:
    json.dump(schema_with_title, output_bestand, indent=2)

print("Het bijgewerkte JSON-schema is opgeslagen in:", output_bestandspad)