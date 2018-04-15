# PROYECTO DE EJEMPLO

Usaremos esta aplicación Ruby on Rails para mostrar ejemplos básicos en la ayudantía. Se separarán los pasos en commits para que puedan revisar el historial de la aplicación.

## Ayudantía 1: Setup

Por favor revisa [la guía de setup de la primera ayudantía](https://github.com/IIC2143-2018-1/syllabus-1/blob/master/ayudantias/ayudantia01_setup.pdf).

## Ayudantía 4: CRUD

En esta ayudantía crearemos 3 modelos con sus respectivas vistas y controladores. Los 3 modelos se enmarcan en el [proyecto del semestre pasado](https://github.com/IIC2143-2017/syllabus/blob/master/Proyecto/Enunciado%20Proyecto%20Semestral.pdf).

### Artista

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
>Ahora se puede escribir `dexec` en vez de `docker-compose exec web` en todos los comandos.