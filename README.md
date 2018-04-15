# PROYECTO DE EJEMPLO

Usaremos esta aplicación Ruby on Rails para mostrar ejemplos básicos en la ayudantía. Se separarán los pasos en commits para que puedan revisar el historial de la aplicación.

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

* `db/migrate/<timestamp>_create_artists.rb` donde está la migración (una clase) que ejecutará los cambios necesarios en la base de datos para poder guardar artistas.
* `app/models/artist.rb` que tiene la clase `Artist` de nuestro modelo.
* `test/fixtures/artists.yml` y `test/models/artist_test.rb` para poder testear nuestro modelo. Veremos *testing* más adelante en el semestre.

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

```ruby
# app/models/artist.rb

class Artist < ApplicationRecord
  has_many :albums, dependent: :destroy
end

```

Puedes notar 2 cosas:

1. El primer argumento de `has_many` está en plural.
2. El segundo argumento `dependent: :destroy` está indicando que en caso de que un artista sea eliminado, sus álbumes también deben ser destruidos.

Segundo, en `Album` debemos revisar que se ejecute `belongs_to`, para indicar el sentido opuesto de esta asociación entre artistas y álbumes. Esto puede haber sido agregado por Rails. Entonces, el modelo debiese quedar así:

```ruby
# app/models/album.rb

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

```ruby
# app/models/song.rb

class Song < ApplicationRecord
  belongs_to :album
end

```

```ruby
# app/models/album

class Album < ApplicationRecord
  belongs_to :artist
  has_many :songs, dependent: :destroy
end

```

### Migraciones

Bacán, hasta ahora tenemos todos los modelos que queremos. Pero, ¿y la base de datos?. Para ejecutar cambios en la base de datos usamos las migraciones y debemos correrlas.

Por ejemplo, veamos la migración de los álbumes.

```ruby
# db/migrate/<timestamp>_create_albums.rb

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

Una última cosa. Cada vez que se corre una migración, se actualiza el archivo `db/schema.rb`. Este archivo tiene todo lo necesario para replicar la misma estructura de tablas en una nueva base de datos.