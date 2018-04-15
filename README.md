# PROYECTO DE EJEMPLO

Usaremos esta aplicación Ruby on Rails para mostrar ejemplos básicos en la ayudantía. Se separarán los pasos en commits para que puedan revisar el historial de la aplicación.

Por simplicidad, casi todo el desarrollo de este proyecto se hará en la rama `master`. En su proyecto, preocúpese de crear una rama por *feature* desde la rama `development` y de no trabajar directamente en `master`.

Si encuentras algún error en este proyecto (en particular en este README), por favor haz un *fork* de este repositorio y luego una *pull request* corrigiéndolo.

## Ayudantía 1: Setup

Por favor revisa [la guía de setup de la primera ayudantía](https://github.com/IIC2143-2018-1/syllabus-1/blob/master/ayudantias/ayudantia01_setup.pdf).

## Ayudantía 4: CRUD

En esta ayudantía crearemos 3 modelos con sus respectivas vistas y controladores. Los 3 modelos se enmarcan en el [proyecto del semestre pasado](https://github.com/IIC2143-2017/syllabus/blob/master/Proyecto/Enunciado%20Proyecto%20Semestral.pdf).

### Modelos

#### Artista

Nuestro primer modelo será un Artista de música. Por ahora nos basta que tenga solo un nombre:

```bash
docker-compose exec web rails generate model Artist name:string
```

¿Qué está pasando aquí? Vamos por partes:

1. `docker-compose exec web` está indicando que queremos ejecutar un comando dentro del contenedor creado con la imagen de nombre `web`. Todo lo que venga después de esta parte será el comando ejecutado dentro de ese contenedor.
2. `rails` es para ejecutar algún comando de la gema Rails.
3. `generate model` es un comando de Rails que nos creará todos los archivos asociados a un modelo.
4. `Artist` es el nombre de nuestro modelo. Notar que este nombre tiene que ser en singular y preferiblemente en inglés. Rails convertirá éste a su forma en plural en ciertos contextos, como el nombre de la tabla asociada en la base de datos, que se llamará `artists`.
5. `name:string` está indicando un atributo que tendrá este modelo y el tipo de dato del atributo. En este caso, estamos indicando que queremos ser capaces de guardar un *string* que indique el nombre.

El *output* esperado de este comando es algo similar a esto:

```
Running via Spring preloader in process 57
      invoke  active_record
      create    db/migrate/20180415170500_create_artists.rb
      create    app/models/artist.rb
      invoke    test_unit
      create      test/models/artist_test.rb
      create      test/fixtures/artists.yml
```

Puedes ver que se crearon 4 archivos:

* [`db/migrate/<timestamp>_create_artists.rb`](./db/migrate/20180415170500_create_artists.rb) donde está la migración (una clase) que ejecutará los cambios necesarios en la base de datos para poder guardar artistas.
* [`app/models/artist.rb`](./app/models/artist.rb) que tiene la clase `Artist` de nuestro modelo.
* [`test/fixtures/artists.yml`](./test/fixtures/artists.yml) y [`test/models/artist_test.rb`](./test/models/artist_test.rb) para poder testear nuestro modelo. Veremos *testing* más adelante en el semestre.

> Si te molesta escribir mucho `docker-compose exec web`, puedes crear un alias en tu terminal de la siguiente forma:
> 
>```bash
>alias dexec='docker-compose exec web'
>```
>
>Ahora se puede escribir `dexec` en vez de `docker-compose exec web` en todos los comandos. En verdad, el nombre del comando puede ser lo que tú quieras, pero preocúpate de que no sea algún comando ya existente.

#### Álbum

Un álbum tendrá un nombre, un año de lanzamiento y una referencia al artista al que pertenece

```bash
docker-compose run exec rails g model Album name:string year:integer artist:references
```

> Puedes notar que `generate` se puede abreviar con una `g`.

Como un álbum pertencece a un solo artista (en nuestro proyecto simplificado) y un artista puede tener más de un álbum (a menos de que tenga solo un éxito 😥), tenemos que indicarle a nuestros modelos que están asociados entre ellos.

Primero, en `Artist`, ejecutaremos el método `has_many`.

[`app/models/artist.rb`](./app/models/artist.rb)

```ruby
class Artist < ApplicationRecord
  has_many :albums, dependent: :destroy
end

```

Puedes notar 2 cosas:

1. El primer argumento de `has_many` está en plural.
2. El segundo argumento `dependent: :destroy` está indicando que en caso de que un artista sea eliminado, sus álbumes también deben ser destruidos.

Segundo, en `Album` debemos revisar que se ejecute `belongs_to`, para indicar el sentido opuesto de esta asociación entre artistas y álbumes. Esto puede haber sido agregado por Rails. Entonces, el modelo debiese quedar así:

[`app/models/album.rb`](./app/models/album.rb)

```ruby
class Album < ApplicationRecord
  belongs_to :artist
end
```

Puedes notar que `:artist` está en singular.

#### Canción

Ahora agregaremos nuestro último modelo. Una canción tendrá un nombre, una duración y pertenecerá a un álbum.

```bash
docker-compose exec web rails g model Song name:string length:integer album:references
```

De la misma forma anterior, agregaremos su asociación con álbum en los modelos.

[`app/models/song.rb`](./app/models/song.rb)

```ruby
class Song < ApplicationRecord
  belongs_to :album
end

```

[`app/models/album.rb`](./app/models/album.rb)

```ruby
class Album < ApplicationRecord
  belongs_to :artist
  has_many :songs, dependent: :destroy
end

```

### Migraciones

Bacán, hasta ahora tenemos todos los modelos que queremos. Pero, ¿y la base de datos?. Para ejecutar cambios en la base de datos usamos las migraciones y debemos correrlas.

Por ejemplo, veamos la migración de los álbumes.

[`db/migrate/<timestamp>_create_albums.rb`](./db/migrate/20180415171230_create_albums.rb)

```ruby
class CreateAlbums < ActiveRecord::Migration[5.1]
  def change
    create_table :albums do |t|
      t.string :name
      t.integer :year
      t.references :artist, foreign_key: true

      t.timestamps
    end
  end
end

```

Podemos notar que esta migración creará una tabla llamada `albums`. El bloque (`do ... end`) que recibe esta función indica qué cosas se harán con esa tabla (que está representada con el argumento `t`). Por ahora la tabla tendrá 3 columnas explícitas: `name`, `year` y `artist` (que corresponde al id de algún artista en su propia tabla, por ello se indica que es una `foreign_key`). Finalmente, esta tabla también tendrá columnas con los *timestamps* de creación y actualización.

Es importante mencionar que las migraciones tienen dos sentidos: up y down. 

* Up indica los cambios que se ejecutarán en la base de datos y se definen en el método `up` de la migración.
* Down indica los cambios para deshacer lo hecho por Up y se definen en el método `down`.

En Rails también se puede definir un solo método `change` que es obvio cómo revertir, y eso es lo que tenemos en nuestras migraciones por ahora.

Ahora, ejecutemos los cambios:

```bash
docker-compose exec web rails db:migrate
```

El *output* debiese ser similar a éste:

```
== 20180415170500 CreateArtists: migrating ====================================
-- create_table(:artists)
   -> 0.0190s
== 20180415170500 CreateArtists: migrated (0.0200s) ===========================

== 20180415171230 CreateAlbums: migrating =====================================
-- create_table(:albums)
   -> 0.0256s
== 20180415171230 CreateAlbums: migrated (0.0271s) ============================

== 20180415172735 CreateSongs: migrating ======================================
-- create_table(:songs)
   -> 0.0303s
== 20180415172735 CreateSongs: migrated (0.0305s) =============================
```

Podemos revisar el estado de nuestras migraciones en cualquier momento con

```
docker-compose exec web rails db:migrate:status
```

y obtener una tabla como la siguiente:

```
database: example-1_development

 Status   Migration ID    Migration Name
--------------------------------------------------
   up     20180415170500  Create artists
   up     20180415171230  Create albums
   up     20180415172735  Create songs

```

Cuando creemos nuevos modelos con sus migraciones, pero no las ejecutemos, éstas apareceran en esta tabla pero con *status* `down`.

Una última cosa. Cada vez que se corre una migración, se actualiza el archivo [`db/schema.rb`](./db/schema.rb). Este archivo tiene todo lo necesario para replicar la misma estructura de tablas en una nueva base de datos.

### Una pausa: La consola de Rails

Ahora que tenemos clases en nuestra aplicación podemos jugar con ellas. Para ello, abramos la consola de Rails donde podremos crear instancias de nuestros modelos.

Para abrir la consola puedes ejecutar

```
docker-compose exec web rails console
```

> De la misma forma que con `generate`, puedes abreviar `console` con una `c`. Luego, otra forma de abrir la consola es `docker-compose exec web rails c`.
 
La consola se ve más o menos así:

```ruby
Running via Spring preloader in process 213
Loading development environment (Rails 5.1.5)
irb(main):001:0>
```

Para no saturar nuestros *outputs*, de ahora en adelante se mostrarán los *prompts* en esta guía como `>>`, y las ejecuciones como `=>`.

Entonces, creemos un artista con un álbum y una canción.

```ruby
>> our_artist = Artist.new(name: 'Mazapan')
=> #<Artist id: nil, name: "Mazapan", created_at: nil, updated_at: nil>
>> our_artist.save
   (0.9ms)  BEGIN
  SQL (1.4ms)  INSERT INTO "artists" ("name", "created_at", "updated_at") VALUES ($1, $2, $3) RETURNING"id"  [["name", "Mazapan"], ["created_at", "2018-04-15 18:11:59.022259"], ["updated_at", "2018-04-15 18:11:59.022259"]]
   (2.8ms)  COMMIT
=> true
```

El método `new` crea un nuevo artista, pero no lo guarda inmediatamente en la base de datos. Puedes notar que éste solo se guarda cuando ejecutamos `save`. Si quieres crear y guardar inmediatamente, puedes usar el método `create`.

Ahora, creemos un álbum asociado a este artista y una canción del álbum:

```ruby
>> our_album = Album.create(artist: our_artist, name: 'A La Ronda', year: '1982')
   (0.5ms)  BEGIN
  SQL (5.7ms)  INSERT INTO "albums" ("name", "year", "artist_id", "created_at", "updated_at") VALUES ($1, $2, $3, $4, $5) RETURNING "id"  [["name", "A La Ronda"], ["year", 1982], ["artist_id", 1], ["created_at", "2018-04-15 18:15:02.105574"], ["updated_at", "2018-04-15 18:15:02.105574"]]
   (6.4ms)  COMMIT
=> #<Album id: 1, name: "A La Ronda", year: 1982, artist_id: 1, created_at: "2018-04-15 18:15:02", updated_at: "2018-04-15 18:15:02">
>> our_song = Song.create(name: 'Una Cuncuna', length: 105, album: our_album)
   (0.4ms)  BEGIN
  SQL (2.8ms)  INSERT INTO "songs" ("name", "length", "album_id", "created_at", "updated_at") VALUES ($1, $2, $3, $4, $5) RETURNING "id"  [["name", "Una Cuncuna"], ["length", 105], ["album_id", 1], ["created_at", "2018-04-15 18:16:48.768674"], ["updated_at", "2018-04-15 18:16:48.768674"]]
   (3.3ms)  COMMIT
=> #<Song id: 1, name: "Una Cuncuna", length: 105, album_id: 1, created_at: "2018-04-15 18:16:48", updated_at: "2018-04-15 18:16:48">
```

Ahora, podemos ver todos los artistas:

```ruby
>> Artist.all
  Artist Load (3.4ms)  SELECT  "artists".* FROM "artists" LIMIT $1  [["LIMIT", 11]]
=> #<ActiveRecord::Relation [#<Artist id: 1, name: "Mazapan", created_at: "2018-04-15 18:11:59", updated_at: "2018-04-15 18:11:59">]>
```

Podemos ver todos los álbumes de un artista:

```ruby
>> our_artist.albums
  Album Load (0.8ms)  SELECT  "albums".* FROM "albums" WHERE "albums"."artist_id" = $1 LIMIT $2  [["artist_id", 1], ["LIMIT", 11]]
=> #<ActiveRecord::Associations::CollectionProxy [#<Album id: 1, name: "A La Ronda", year: 1982, artist_id: 1, created_at: "2018-04-15 18:15:02", updated_at: "2018-04-15 18:15:02">]>
```

Podemos buscar alguna canción en particular por alguno de sus atributos.

```ruby
>> Song.find_by(length: 105)
  Song Load (0.7ms)  SELECT  "songs".* FROM "songs" WHERE "songs"."length" = $1 LIMIT $2  [["length", 105], ["LIMIT", 1]]
=> #<Song id: 1, name: "Una Cuncuna", length: 105, album_id: 1, created_at: "2018-04-15 18:16:48", updated_at: "2018-04-15 18:16:48">
```

O buscar varias instancias de acuerdo a alguno de sus atributos:

```ruby
>> Song.where(album: our_album)
  Song Load (3.1ms)  SELECT  "songs".* FROM "songs" WHERE "songs"."album_id" = 1 LIMIT $1  [["LIMIT", 11]]
=> #<ActiveRecord::Relation [#<Song id: 1, name: "Una Cuncuna", length: 105, album_id: 1, created_at: "2018-04-15 18:16:48", updated_at: "2018-04-15 18:16:48">, #<Song id: 2, name: "La Señora Mariposa", length: 76, album_id: 1, created_at: "2018-04-15 18:24:09", updated_at: "2018-04-15 18:24:09">]>

```