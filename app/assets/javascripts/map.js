(function() {
  var I18n, other_domain, other_locale,
    indexOf = [].indexOf || function(item) {
      for (var i = 0, l = this.length; i < l; i++) {
        if (i in this && this[i] === item) return i;
      }
      return -1;
    };

  $.fn.hasAttr = function(attr) {
    return _.any(this, function(el) {
      return typeof $(el).attr(attr) !== 'undefined';
    });
  };

  $.fn.toggleAttr = function(attr, state) {
    var isBoolean;
    isBoolean = typeof state === 'boolean';
    return this.each(function() {
      var self;
      self = $(this);
      if (!isBoolean) {
        state = !self.hasAttr(attr);
      }
      if (state) {
        return self.attr(attr, attr);
      } else {
        return self.removeAttr(attr);
      }
    });
  };

  I18n = {
    en: {
      locale: 'en',
      other_locale: 'fr',
      abbr_month_names: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
      time_format: '%{b} %{e}, %{l}%{P}',
      accuracy: 'You are within %{radius} meters of this point',
      condition: 'In %{condition} condition',
      unknown_condition: 'Ice condition not available',
      call_to_action: "You can contribute by asking the city to publish this rink’s conditions:",
      request_email: 'Email',
      request_phone: 'Phone',
      or_call: 'or call',
      add_favorite: 'Add to favorites',
      remove_favorite: 'Remove from favorites',
      explanation: 'Going skating? Let your friends know:',
      tweet: "I’m going",
      tweet_text_PSE: "I’m going to play hockey at %{park}",
      tweet_text_PPL: "I’m going skating at %{park}",
      tweet_text_PP: "I’m going skating at %{park}",
      _PSE: 'Team sports',
      _PPL: 'Free skating',
      _PP: 'Landscaped',
      'Aire de patinage libre': 'Free skating area',
      'Grande patinoire avec bandes': 'Big rink with boards',
      'Patinoire avec bandes': 'Rink with boards',
      'Patinoire de patin libre': 'Free skating rink',
      'Patinoire décorative': 'Decorative rink',
      'Patinoire entretenue par les citoyens': 'Rink maintained by citizens',
      'Patinoire réfrigérée': 'Refrigerated rink',
      'Patinoire réfrigérée Bleu-Blanc-Bouge': 'Refrigerated rink Bleu-Blanc-Bouge',
      'Petite patinoire avec bandes': 'Small rink with boards',
      open: 'Open',
      closed: 'Closed',
      cleared: 'Cleared',
      flooded: 'Flooded',
      resurfaced: 'Resurfaced',
      Excellente: 'excellent',
      Bonne: 'good',
      Mauvaise: 'bad',
      rinks: 'rinks',
      rinks_url: 'rinks/%{id}-%{slug}',
      favorites_url: 'favorites',
      'sports-dequipe': 'team-sports',
      'patin-libre': 'free-skating',
      'paysagee': 'landscaped',
      'ouvert': 'open',
      'deblaye': 'cleared',
      'arrose': 'flooded',
      'resurface': 'resurfaced',
      'favories': 'favorites',
      PSE: 'team-sports',
      PPL: 'free-skating',
      PP: 'landscaped',
      C: 'landscaped',
      download: 'Download'
    },
    fr: {
      locale: 'fr',
      other_locale: 'en',
      abbr_month_names: ['jan.', 'fév.', 'mar.', 'avr.', 'mai', 'juin', 'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'],
      time_format: '%{b} %{e} à %{H}h',
      accuracy: 'Vous êtes à moins de %{radius} mètres de ce point',
      condition: 'En %{condition} condition',
      unknown_condition: 'État de la patinoire non disponible',
      call_to_action: "Vous pouvez contribuer en demandant à la ville de publier l’état de cette patinoire:",
      request_email: 'Courriel',
      request_phone: 'Téléphone',
      or_call: 'ou appelez le',
      add_favorite: 'Ajouter aux favories',
      remove_favorite: 'Supprimer des favories',
      explanation: 'Vous allez patiner? Informez vos amis:',
      tweet: "J’y vais",
      tweet_text_PSE: 'Je vais jouer au hockey à %{park}',
      tweet_text_PPL: 'Je vais patiner à %{park}',
      tweet_text_PP: 'Je vais patiner à %{park}',
      _PSE: "Sports d’équipe",
      _PPL: 'Patin libre',
      _PP: 'Paysagée',
      open: 'Ouverte',
      closed: 'Fermée',
      cleared: 'Déblayée',
      flooded: 'Arrosée',
      resurfaced: 'Resurfacée',
      Excellente: 'excellente',
      Bonne: 'bonne',
      Mauvaise: 'mauvaise',
      rinks: 'patinoires',
      rinks_url: 'patinoires/%{id}-%{slug}',
      favorites_url: 'favories',
      PSE: 'sports-dequipe',
      PPL: 'patin-libre',
      PP: 'paysagee',
      C: 'paysagee',
      download: 'Télécharger'
    }
  };

  window.t = function(string, args) {
    var current_locale, key, value;
    if (args == null) {
      args = {};
    }
    current_locale = args.locale || locale;
    string = I18n[current_locale][string] || string;
    for (key in args) {
      value = args[key];
      string = string.replace(RegExp("%\\{" + key + "\\}", "g"), value);
    }
    return string;
  };

  window.format_date = function(string) {
    var args, date, hour;
    date = new Date(Date.parse(string));
    hour = date.getHours();
    args = {
      b: t('abbr_month_names')[date.getMonth()],
      e: date.getDate(),
      H: hour,
      l: hour > 12 ? hour - 12 : (hour === 0 ? 12 : hour),
      P: hour > 11 ? 'pm' : 'am'
    };
    return t('time_format', args);
  };

  (function(_getFragment) {
    return Backbone.History.prototype.getFragment = function() {
      return _getFragment.apply(this, arguments).replace(/\/$/, '').replace(/\?.*/, '');
    };
  })(Backbone.History.prototype.getFragment);

  other_locale = t('other_locale');

  other_domain = $('#language a').attr('href').match(/^http:\/\/[^\/]+\//)[0].replace(t('locale'), other_locale);

  (function(_navigate) {
    return Backbone.History.prototype.navigate = function() {
      _navigate.apply(this, arguments);
      return $('#language a').attr('href', _.reduce(['about', 'contact', 'donate', 'api', 'rinks', 'favorites', 'sports-dequipe', 'patin-libre', 'paysagee', 'ouvert', 'deblaye', 'arrose', 'resurface'], function(string, component) {
        return string.replace(t(component), t(component, {
          locale: other_locale
        }));
      }, other_domain + Backbone.history.getFragment()));
    };
  })(Backbone.History.prototype.navigate);

  $(function() {
    var ControlView, ControlsView, map, Options, Rink, RinkSet, Router, Routes, Singleton, controls;
    window.debug = env === 'development';
    $('.control').tooltip();
    $.smartbanner({
      title: "Patiner Montréal",
      authors: {
        'android': 'Android',
        'ios': 'iPhone'
      },
      price: null,
      appStoreLanguage: t('locale'),
      icons: {
        'android': '/assets/app-icon-android.png',
        'ios': '/assets/app-icon-ios.png'
      },
      iOSUniversalApp: false,
      button: t('download'),
      appendToSelector: 'header'
    });
    $(window).on('load', function(e) {
      return $('#share-toggle').fadeIn();
    });
    $('#share-toggle').on('click', function(e) {
      e.preventDefault();
      $('#social .navbar').slideToggle('fast');
    });
    map = new mapboxgl.Map({
      container: 'map',
      style: '/assets/maptiler-style.json',
      center: [-73.63, 45.53],
      zoom: 13,
      minzoom: 11,
      maxzoom: 18,
      maxBounds: [
        [-74.447699, 45.170459],
        [-73.147435, 46.035873]
      ],
      bearing: -34
    });
    map.addControl(
      new mapboxgl.GeolocateControl({
        positionOptions: {
          enableHighAccuracy: true
        },
        trackUserLocation: true
      }), 'top-left');
    map.addControl(new mapboxgl.NavigationControl, 'top-left');

    var FeatureMarkerView = Backbone.View.extend({
      template: _.template($('#popup-template').html()),

      initialize: function() {
        // Deserialize attributes correctly
        this.attributes.arrondissement = JSON.parse(this.attributes.arrondissement)
        this.attributes.conditions = JSON.parse(this.attributes.conditions)
        if (!JSON.parse(this.attributes.tel)) {
          this.attributes.tel = null
        }
        // Build rink URL, for twitter sharing
        this.attributes.url = t('rinks_url', {
          id: this.attributes.id,
          slug: this.attributes.slug
        })

        // TODO
        this.attributes.favorite = false
      },

      render: function() {
        this.setElement(this.template(this.attributes))
        return this;
      }
    });

    FeatureModel = Backbone.Model.extend({});

    map.on('click', 'rinks', function(e) {
      $('#social .navbar').slideUp('fast')

      var features = map.queryRenderedFeatures(e.point);
      //     console.log(features.properties)
      var coordinates = e.features[0].geometry.coordinates.slice();
      map.flyTo({
        center: e.features[0].geometry.coordinates
      });

      var featureModel = new FeatureModel(e.features[0].properties)
      var featureMarkerView = new FeatureMarkerView(featureModel)
      var render = featureMarkerView.render()
      //     console.log(render)
      // Ensure that if the map is zoomed out such that multiple
      // copies of the feature are visible, the popup appears
      // over the copy being pointed to.
      while (Math.abs(e.lngLat.lng - coordinates[0]) > 180) {
        coordinates[0] += e.lngLat.lng > coordinates[0] ? 360 : -360;
      }

      new mapboxgl.Popup({
          anchor: "bottom",
          closeButton: false,
          offset: [0, -15]
        })
        .setLngLat(coordinates)
        .setHTML(render.el.outerHTML)
        // .setHTML(e.features[0].properties.conditions)
        .addTo(map);
    });

    Rink = Backbone.Model.extend({
      initialize: function(attributes) {
        if ('C' === this.get('genre')) {
          this.set({
            genre: 'PP'
          });
        }
        this.set({
          url: t('rinks_url', {
            id: this.get('id'),
            slug: this.get('slug')
          })
        });
        return Backbone.sync('read', this, {
          success: (function(_this) {
            return function(response) {
              return _this.set({
                favorite: response.favorite
              });
            };
          })(this),
          error: (function(_this) {
            return function(message) {};
          })(this)
        });
      },
      defaults: {
        favorite: false,
        visible: false
      },
      show: function() {
        return this.set({
          visible: true
        });
      },
      hide: function() {
        return this.set({
          visible: false
        });
      },
      toggle: function() {
        return this.save({
          favorite: !this.get('favorite')
        });
      }
    });
    RinkSet = Backbone.Collection.extend({
      model: Rink,
      localStorage: new Store('rinks'),
      showIfMatching: function(kinds, statuses) {
        this.each(function(rink) {
          var ref;
          return rink.set({
            visible: (ref = rink.get('genre'), indexOf.call(kinds, ref) >= 0) && _.all(statuses, function(status) {
              return rink.get(status);
            })
          });
        });
        return this.trigger('changeAll', kinds, statuses);
      },
      showIfFavorite: function() {
        this.each(function(rink) {
          return rink.set({
            visible: rink.get('favorite')
          });
        });
        return this.trigger('changeAll');
      },
      visible: function() {
        return this.filter(function(rink) {
          return rink.get('visible');
        });
      },
      favorites: function() {
        return this.filter(function(rink) {
          return rink.get('favorite');
        });
      }
    });
    map.on('popupclose', function(event) {
      if (!Options.get('openingPopup')) {
        return Backbone.history.navigate(Options.get('beforePopup'), true);
      }
    });
    map.on('load', function(event) {
      map.addSource('rinks-source', {
        type: 'geojson',
        data: geojson
      });
      return map.addLayer({
        'id': 'rinks',
        'type': 'symbol',
        'source': 'rinks-source',
        'layout': {
          'icon-allow-overlap': true,
          'icon-image': ['concat', ['get', 'genre'], '-', ['case', ['==', ['get', 'conditions'], null], 'na', ['get', 'ouvert', ['object', ['get', 'conditions']]], 'on', 'off']]
        }
      });
    });
    ControlsView = Backbone.View.extend({
      initialize: function() {
        _.each(['PP', 'PPL', 'PSE'], (function(_this) {
          return function(id) {
            return new ControlView({
              collection: _this.collection,
              el: "#" + id,
              type: 'kinds'
            });
          };
        })(this));
        _.each(['ouvert', 'deblaye', 'arrose', 'resurface'], (function(_this) {
          return function(id) {
            return new ControlView({
              collection: _this.collection,
              el: "#" + id,
              type: 'statuses'
            });
          };
        })(this));
        return new ControlView({
          collection: this.collection,
          el: '#favories'
        });
      }
    });
    ControlView = Backbone.View.extend({
      initialize: function(attributes) {
        this.id = $(this.el).attr('id');
        this.type = attributes.type;
        return this.collection.bind('changeAll', this.render, this);
      },
      events: {
        click: 'toggle'
      },
      render: function(kinds, statuses) {
        var ref, ref1, state;
        if (this.type != null) {
          if (!this.favoritesUrl()) {
            state = (ref = this.id, indexOf.call(kinds, ref) >= 0) || (ref1 = this.id, indexOf.call(statuses, ref1) >= 0);
            this.$('.icon').toggleClass('active', state);
          }
        } else {
          this.$('.icon').toggleClass('active', this.favoritesUrl());
        }
        return this;
      },
      toggle: function(state) {
        var filters, kinds, ref, ref1, statuses;
        map.closePopup();
        if (this.type != null) {
          ref = this.filterUrl() ? this.fromUrl(this.currentUrl()) : this.fromUI(), kinds = ref[0], statuses = ref[1];
          if (this.type === 'kinds') {
            filters = kinds;
          } else {
            filters = statuses;
          }
          if (ref1 = this.id, indexOf.call(filters, ref1) >= 0) {
            filters = _.without(filters, this.id);
          } else {
            filters.push(this.id);
          }
          if (this.type === 'kinds') {
            kinds = filters;
          } else {
            statuses = filters;
          }
          return Backbone.history.navigate(this.toUrl(kinds, statuses), true);
        } else {
          if (this.$('.icon').hasClass('active')) {
            return Backbone.history.navigate(Options.get('beforeFavorites'), true);
          } else {
            if (!this.favoritesUrl()) {
              Options.save({
                beforeFavorites: this.currentUrl()
              });
            }
            return Backbone.history.navigate(t('favorites_url'), true);
          }
        }
      }
    });
    Router = Backbone.Router.extend({
      initialize: function(attributes) {
        return this.collection = attributes.collection;
      },
      routes: {
        '': 'default',
        'favorites': 'favorites',
        'favories': 'favorites',
        'f': 'filter',
        'f/*filters': 'filter',
        'rinks/:id': 'show',
        'patinoires/:id': 'show'
      },
      favorites: function() {
        return this.collection.showIfFavorite();
      },
      filter: function(splat) {
        var ref;
        return (ref = this.collection).showIfMatching.apply(ref, this.fromUrl(splat));
      },
      show: function(id) {
        var ref, rink;
        rink = this.collection.get(id.match(/^\d+/)[0]);
        if (!rink.get('visible')) {
          (ref = this.collection).showIfMatching.apply(ref, this.fromUrl(this.rootUrl()));
        }
        return rink.view.openPopup();
      },
      "default": function() {
        return this.navigate(this.rootUrl(), true);
      }
    });
    window.Helpers = {
      kinds: {
        'team-sports': 'PSE',
        'sports-dequipe': 'PSE',
        'free-skating': 'PPL',
        'patin-libre': 'PPL',
        'landscaped': 'PP',
        'paysagee': 'PP'
      },
      statuses: {
        'open': 'ouvert',
        'ouvert': 'ouvert',
        'cleared': 'deblaye',
        'deblaye': 'deblaye',
        'flooded': 'arrose',
        'arrose': 'arrose',
        'resurfaced': 'resurface',
        'resurface': 'resurface'
      },
      numberToPhone: function(number, options) {
        if (options == null) {
          options = {};
        }
        number = number.replace(/([0-9]{3})([0-9]{3})([0-9]{4})/, '($1) $2-$3');
        if (options.extension) {
          number += ' x' + options.extension;
        }
        return number;
      },
      currentUrl: function() {
        return Backbone.history.getFragment();
      },
      rootUrl: function() {
        return this.toUrl(['PP', 'PPL', 'PSE'], []);
      },
      filterUrl: function() {
        return this.currentUrl().indexOf('f/') >= 0;
      },
      rinkUrl: function() {
        return this.currentUrl().indexOf(t('rinks')) >= 0;
      },
      favoritesUrl: function() {
        return this.currentUrl() === t('favorites_url');
      },
      fromUI: function() {
        var kinds, statuses;
        kinds = _.filter(['PP', 'PPL', 'PSE'], function(filter) {
          return $("#" + filter + " .icon").hasClass('active');
        });
        statuses = _.filter(['ouvert', 'deblaye', 'arrose', 'resurface'], function(filter) {
          return $("#" + filter + " .icon").hasClass('active');
        });
        return [kinds, statuses];
      },
      fromUrl: function(splat) {
        var i, kinds, len, part, ref, statuses;
        kinds = [];
        statuses = [];
        if (splat != null) {
          ref = splat.split('/');
          for (i = 0, len = ref.length; i < len; i++) {
            part = ref[i];
            if (part in this.kinds) {
              kinds.push(this.kinds[part]);
            } else if (part in this.statuses) {
              statuses.push(this.statuses[part]);
            } else if (part === 'f') {

            } else {
              if (window.debug) {
                console.log("Unknown filter: " + part);
              }
            }
          }
        }
        return [kinds, statuses];
      },
      toUrl: function(kinds, statuses) {
        return 'f/' + _.uniq(_.map(kinds.sort().concat(statuses.sort()), function(filter) {
          return t(filter);
        })).join('/');
      },
      body: function(arrondissement) {
        var string;
        string = arrondissement.name ? "Attn: " + arrondissement.name + "\r\n\r\n" : '';
        string += "Serait-il possible de publier l'état de vos patinoires extérieures comme le font plusieurs arrondissements à la Ville de Montréal ? Voir: http://ville.montreal.qc.ca/portal/page?_pageid=5798,94909650&_dad=portal&_schema=PORTAL\r\n\r\nMerci.";
        return encodeURIComponent(string);
      }
    };
    Singleton = Backbone.Model.extend({
      localStorage: new Store('options')
    });
    Options = new Singleton({
      id: 1,
      beforeFavorites: Helpers.rootUrl(),
      beforePopup: Helpers.rootUrl(),
      openingPopup: false
    });
    _.each([ControlsView, ControlView, Router], function(klass) {
      return _.extend(klass.prototype, Helpers);
    });
    window.Rinks = new RinkSet;
    Rinks.reset(geojson);
    Routes = new Router({
      collection: Rinks
    });
    controls = new ControlsView({
      el: '#controls',
      collection: Rinks
    });
    Backbone.history.start({
      pushState: true
    });
  });

}).call(this);
