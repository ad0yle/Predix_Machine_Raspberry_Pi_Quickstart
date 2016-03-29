Polymer({

  is: 'px-chart',

  /**
   * Properties block, expose attribute values to the DOM via 'reflect'
   *
   * @property properties
   * @type Object
   */
  properties: {

    /**
     * Determines that what type of chart to display.
     *
     * This type influences the series type for the navigator, the x-axis display, etc.
     *
     * This does NOT affect the type of the series displayed on the graph.  To change the type of series, change
     * the <px-chart-series-*> web component to line, bar, histogram, etc.
     *
     * Can only be statically configured (not data-bindable).
     *
     * Accepts values of 'line', 'scatter' or 'bar'.
     *
     * @type {String}
     * @default line
     */

    type: {
      type: String,
      value: 'line'
    },

    /**
     * Whether to show the zoom-able / scroll-able area at the bottom of the chart.
     *
     * Can only be statically configured (not data-bindable).
     *
     * @type {Boolean}
     * @default false
     */
    navigatorDisabled: {
      type: Boolean,
      value: false
    },

    /**
     * See http://api.highcharts.com/highcharts#chart.resetZoomButton
     *
     * @default
     * @private
     */
    resetZoomButton: {
      type: Object,
      value: {
        theme: {
          display: 'none'
        }
      }
    },

    /**
     * @private
     */
    chartZoomed: {
      type: Boolean,
      value: false,
      reflectToAttribute: true,
      notify: true,
      observer: 'chartZoomedObserver'
    },

    /**
     * See http://api.highcharts.com/highcharts#chart.events
     *
     * @default redraw function()
     * @private
     */
    events: {
      type: Object,
      value: {
        redraw: function() {

          var extremes = this.xAxis[0].getExtremes();
          var tsChart = Polymer.dom(this.renderTo).parentNode.parentNode;

          if (tsChart.debounce) {//in export case this function will be called outside the realm of a polymer components
            tsChart.debounce(
              'set-extremes', function() {
                if(extremes.min !== undefined && extremes.max !== undefined && extremes.min !== null && extremes.max !== null) {
                  this.rangeMs = {
                    start: extremes.min,
                    end: extremes.max
                  };
                }
              }, 250);
          }
        },
        selection: function(evt) {
          if (evt.originalEvent && evt.originalEvent.shiftKey) {
            return true;
          }
          else if (evt.xAxis) {
            var axis = evt.xAxis[0];
            this.xAxis[0].removePlotBand("selection");
            this.xAxis[0].addPlotBand({
              color: 'rgba(245,245,245,0.4)',
              borderColor: 'rgb(38, 93, 171)',
              borderWidth: 2,
              from: axis.min,
              to: axis.max,
              id: "selection",
              zIndex: 5,

              label: {
                align: "right",
                useHTML: true,
                /* <i class='fa fa-lg u-mr- fa-pencil style-scope px-ts-chart' onclick='alert(this.innerHTML)' title='Annotate'></i> */
                text: "<i class='fa fa-lg fa-search-plus u-mr- style-scope px-chart'" +
                "onclick='" +
                "var wc=this;" +
                "while(!wc.chart) {" +
                "wc = wc.parentNode" +
                "}" +
                "wc.chart.xAxis[0].setExtremes(" + evt.xAxis[0].min + ", " + evt.xAxis[0].max + ");" +
                "wc.chart.xAxis[0].removePlotBand(\"selection\");" +
                "wc.setZoom(true);" +
                "'" +
                "title='Zoom to " +
                moment(evt.xAxis[0].min).format('LLL') + " to " +
                moment(evt.xAxis[0].max).format('LLL') + ";'>" +
                "</i>" +
                "<i class='fa fa-lg u-mr- fa-times style-scope px-chart'" +
                "onclick='" +
                "var wc=this;" +
                "while(!wc.chart) {" +
                "wc = wc.parentNode" +
                "}" +
                "wc.chart.xAxis[0].removePlotBand(\"selection\");" +
                "'" +
                "title='Close selection'>" +
                "</i>"
              }
            });
            return false;
          }
        }
      }
    },

    /**
     * See http://api.highcharts.com/highcharts#plotOptions.series.events
     *
     * @default show & hide series function()
     * @private
     */
    seriesEvents: {
      type: Object,
      value: {
        show: function() {
          var tsChart = Polymer.dom(this.chart.renderTo).parentNode.parentNode;
          tsChart.set('chartState.seriesState', this.chart.series);
        },
        hide: function() {
          var tsChart = Polymer.dom(this.chart.renderTo).parentNode.parentNode;
          tsChart.set('chartState.seriesState', this.chart.series);
        }
      }
    },


    /**
     * The width of the vertical line drawn for series events.
     *
     * Can only be statically configured (not data-bindable).
     *
     * @type Number
     * @default 2
     */
    seriesEventsWidth: {
      type: Number,
      value: 2
    },

    /**
     * The color of the vertical line drawn for series events. Any valid CSS color string is supported.
     *
     * Can only be statically configured (not data-bindable).
     *
     * @type String
     * @default "rgb(59,59,63)"
     */
    seriesEventsColor: {
      type: String,
      value: "rgb(59,59,63)"
    },

    /**
     * See http://api.highcharts.com/highcharts#legend
     *
     * Note that a default legend will be enabled but can set this as an override.
     *
     * Can only be statically configured (not data-bindable).
     *
     * ```
     *    <px-ts-chart legend='{
      *      "enabled": true,
      *      "useHTML": true,
      *      "layout": "vertical",
      *      "verticalAlign": "middle",
      *      "y": 44,
      *      "align": "left",
      *      "floating": true,
      *      "itemMarginTop": 5,
      *      "itemMarginBottom": 5
      *      }'
     *      ...
     *```
     *
     * @type Object
     * @default variable depending on the legendRight property
     */
    legend: {
      type: Object
    },

    /**
     * Whether the legend appears to the right of the chart.
     *
     * Can only be statically configured (not data-bindable).
     *
     * @type Boolean
     * @default false
     */
    legendRight: {
      type: Boolean,
      value: false
    },

    /**
     * See http://api.highcharts.com/highcharts#chart.height
     *
     * Can only be statically configured (not data-bindable).
     *
     * @default 400
     */
    height: {
      type: Number,
      value: 400
    },

    /**
     * See http://api.highcharts.com/highcharts#chart.margin
     *
     * Can only be statically configured (not data-bindable).
     *
     * @default [50,50,30,50] or [100,50,30,50] if zoom buttons exist
     */
    margin: {
      type: Array,
      value: [50, 50, 30, 50]
    },

    /**
     * See http://api.highcharts.com/highstock#chart.spacingBottom
     *
     * Can only be statically configured (not data-bindable).
     *
     * @default 20
     */
    spacingBottom: {
      type: Number,
      value: 20
    },

    /**
     * See http://api.highcharts.com/highcharts#chart.plotBorderWidth
     *
     * Can only be statically configured (not data-bindable).
     *
     * @default 1
     */
    plotBorderWidth: {
      type: Number,
      value: 1
    },

    /**
     * See http://api.highcharts.com/highcharts#chart.zoomType
     *
     * Can only be statically configured (not data-bindable).
     *
     * @default "x"
     */
    zoomType: {
      type: String,
      value: 'x'
    },

    /**
     * URL for the chart export server (converts to image / pdf / etc). Default is null.  Can use "http://export.highcharts.com"
     * for demo purposes only...no intellectual property should go through that server.
     *
     * Can only be statically configured (not data-bindable).
     */
    exportServerUrl: {
      type: String
    },

    /**
     * Holds chart state for binding between charts & serialising chart settings.
     *
     * See the synchronized charts demo (demo-sync.html) for an example.
     *
     * @default {}
     */
    chartState: {
      type: Object,
      value: function() {
        return {};
      },
      notify: true
    },

    /**
     * Selects the chart tooltip type
     *
     * See the charts demo (demo.html) for an example. Can select between normal and condensed
     *
     * @default {}
     */
    tooltipType: {
      type: String,
      value: 'normal'
    },
    /**
     * Mapping of color name to rgb value for use in datavis (axis, navigator, series, etc. colors)
     *
     * Can only be statically configured (not data-bindable).
     *
     * @type {Object}
     * @default Same is datavis colors in px-colors-design
     */
    dataVisColors: {
      type: Object,
      value: {
        "dv-basic-blue": "rgb(93, 165, 218)",
        "dv-basic-orange": "rgb(250, 164, 58)",
        "dv-basic-green": "rgb(96, 189, 104)",
        "dv-basic-pink": "rgb(241, 124, 176)",
        "dv-basic-brown": "rgb(178, 145, 47)",
        "dv-basic-purple": "rgb(178, 118, 178)",
        "dv-basic-yellow": "rgb(222, 207, 63)",
        "dv-basic-red": "rgb(241, 88, 84)",
        "dv-basic-gray": "rgb(77,77,77)",

        "dv-light-blue": "rgb(136, 189, 230)",
        "dv-light-orange": "rgb(251, 178, 88)",
        "dv-light-green": "rgb(144, 205, 151)",
        "dv-light-pink": "rgb(246, 170, 201)",
        "dv-light-brown": "rgb(191, 165, 84)",
        "dv-light-purple": "rgb(188, 153, 199)",
        "dv-light-yellow": "rgb(237, 221, 70)",
        "dv-light-red": "rgb(240, 126, 110)",
        "dv-light-gray": "rgb(140,140,140)",

        "dv-dark-blue": "rgb(38, 93, 171)",
        "dv-dark-orange": "rgb(223, 92, 36)",
        "dv-dark-green": "rgb(5, 151, 72)",
        "dv-dark-pink": "rgb(229, 18, 111)",
        "dv-dark-brown": "rgb(157, 114, 42)",
        "dv-dark-purple": "rgb(123, 58, 150)",
        "dv-dark-yellow": "rgb(199, 180, 46)",
        "dv-dark-red": "rgb(203, 32, 39)",
        "dv-dark-gray": "rgb(0, 0, 0)"
      }
    },

    /**
     * Mapping of color names (from dataVisColors map) in the order they should be applied to chart series.
     *
     * Can only be statically configured (not data-bindable).
     *
     * ```
     *   <px-ts-chart series-color-order='[
     *       "dv-light-pink",
     *       "dv-light-brown",
     *       "dv-light-purple",
     *       "dv-light-yellow"
     *     ]',
     *     ...
     * ```
     *
     * @type {Array}
     */
    seriesColorOrder: {
      type: Array,
      value: [
        "dv-basic-blue",
        "dv-basic-orange",
        "dv-basic-green",
        "dv-basic-pink",
        "dv-basic-brown",
        "dv-basic-purple",
        "dv-basic-yellow",
        "dv-basic-red",
        "dv-basic-gray",

        "dv-light-blue",
        "dv-light-orange",
        "dv-light-green",
        "dv-light-pink",
        "dv-light-brown",
        "dv-light-purple",
        "dv-light-yellow",
        "dv-light-red",
        "dv-light-gray",

        "dv-dark-blue",
        "dv-dark-orange",
        "dv-dark-green",
        "dv-dark-pink",
        "dv-dark-brown",
        "dv-dark-purple",
        "dv-dark-yellow",
        "dv-dark-red",
        "dv-dark-gray"
      ]
    }
  },

  observers: [
    'chartStateUpdated(chartState.*)',
    '_rangeObserver(rangeMs)'
  ],

  /**
   * @private
   */
  defaultYAxisConfig: null,

  /**
   * @private
   */
  defaultSeriesConfig: null,

  /**
   * @private
   */
  defaultLegendTop: {
    enabled: true,
    useHTML: true,
    verticalAlign: 'top',
    align: 'left',
    layout: 'vertical',
    floating: true,
    itemStyle: {
      fontSize: 'inherit',
      fontWeight: 'normal'
    }
  },

  /**
   * @private
   */
  defaultLegendRight: {
    enabled: true,
    verticalAlign: 'top',
    align: 'right',
    layout: 'vertical',
    y: 50,
    x: -125,
    floating: false,
    itemStyle: {
      fontSize: 'inherit',
      fontWeight: 'normal'
    }
  },

  /**
   * @private
   */
  chartStateUpdated: function(evt) {
    var chartExtremesHaveChanged = function(self) {
      var currentChartExtremes = self.chart.xAxis[0].getExtremes();
      return (currentChartExtremes.max !== evt.value.chartZoom.max || currentChartExtremes.min !== evt.value.chartZoom.min);
    };

    var chartAndEventAreValid = function(self) {
      return (self.chart && evt.value.srcElement);
    };

    if (chartAndEventAreValid(this)) {
      if (chartExtremesHaveChanged(this)) {
        if (evt.value.srcElement !== this) {
          this.chart.xAxis[0].setExtremes(evt.value.chartZoom.min, evt.value.chartZoom.max, true);
        }
      }
    }
  },

  _rangeObserver: function() {
    var controlsEl = Polymer.dom(this).querySelector("[data-controls]");
    if (controlsEl && controlsEl.set) {
      controlsEl.set("rangeMs", {
        from: this.rangeMs.start,
        to: this.rangeMs.end
      });
    }
  },

  _initializeMargins: function() {
    var margin = this.margin;
    if (margin && margin[0] === 50) {//adjust top margin if zoom controls not present
      var controls = Polymer.dom(this).querySelector('px-chart-controls');
      if (controls && controls.getAttribute('zoom-buttons') !== 'null' && controls.getAttribute('zoom-buttons') !== '[]') {
        this.margin = [100, margin[1], margin[2], margin[3]];
        if (this.legend && this.legend.align === 'right') {
          this.legend.y = 100;
        }
      }
    }

    margin = this.margin;
    if (margin && margin[1] === 20) {//null out the right margin if default right margin and legend-right so highcharts can use default spacing
      if (this.legend && this.legend.align === 'right') {
        this.margin = [margin[0], null, margin[2], margin[3]];
      }
    }
  },

  _addAxisAndSeries: function() {

    var _this = this;

    var axisEls = Polymer.dom(this).querySelectorAll("px-chart-yaxis");
    var axisElsProcessed = 0;
    if (!axisEls || axisEls.length === 0) {
      //update the default yAxis with our own default options...
      this.defaultYAxisConfig = this.defaultYAxisConfig || document.createElement("px-chart-yaxis");
      this.chart.yAxis[0].update(this.defaultYAxisConfig.buildConfig(this.dataVisColors["dv-dark-gray"]), /*redraw*/false);

      this.addInitialSeries();
    }
    else {
      axisEls.forEach(function(axisEl) {
        var yAxisReadyHandler = function(yAxisOrEvt) {
          var axis = yAxisOrEvt.target || yAxisOrEvt;
          var axisConfig = axis.buildConfig(_this.dataVisColors["dv-dark-gray"]);
          _this.addYAxis(axisConfig, /*noRedraw*/true);
          axisElsProcessed++;
          if (axisElsProcessed === axisEls.length) {
            _this.addInitialSeries();
          }
        };
        axisEl.axisReady ? yAxisReadyHandler(axisEl) : axisEl.addEventListener("y-axis-ready", yAxisReadyHandler);
      });
    }

  },

  /**
   * Lifecycle callback to create the Highchart 'chart' object and consume the config / series elements
   *
   * This is in attached because the size of the parent container for the Highchart is set in attached
   */
  attached: function() {

    if (!this.legend) {
      this.legend = this.legendRight ? this.defaultLegendRight : this.defaultLegendTop;
    }
    this.pointMarkersToggled=false;
    this._initializeMargins();

    this.chart = new Highcharts.StockChart(this.buildConfig());

    this._addAxisAndSeries();
  },

  listeners: {
    'after-set-extremes': 'firechartStateUpdated'
  },

  /**
   * Notify end-user developers values of extremes
   * @private
   */
  firechartStateUpdated: function(evt) {
    var extremes = this.chart.xAxis[0].getExtremes();
    var tsChart = Polymer.dom(this).node;
    tsChart.debounce(
      'set-chart-state', function() {
        this.set('chartState', {chartZoom: extremes, srcElement: this});
      }, 250);
  },

  /**
   * Internal callback for Highcharts config ready
   * @private
   */
  addInitialSeries: function() {
    //find series elements in light dom ("Polymer.dom(this)" vs. "Polymer.dom(this.root)", which would be shadow dom)

    var _this = this;
    var seriesEls = [];
    ["px-chart-series-line", "px-chart-series-histogram", "px-chart-series-bar", "px-chart-series-scatter"].forEach(function(series) {
      var nodelist = Polymer.dom(_this).querySelectorAll(series);
      if (nodelist) {
        nodelist.forEach(function(node) {
          seriesEls.push(node)
        });
      }
    });

    var seriesElReadyHandler = function(seriesElOrEvt) {
      var seriesEl = seriesElOrEvt.target || seriesElOrEvt;
      _this.addSeries(seriesEl.buildConfig(), /*noRedraw*/false);
      seriesEl.addEventListener("data-changed", function(evt) {
        _this.updateSeries(seriesEl.id, evt.detail.value, /*noRedraw*/false);
      });
      seriesEl.addEventListener("data-events-changed", function(evt) {
        _this.updateSeriesEvents({id: seriesEl.id}, evt.detail.value, /*noRedraw*/false);
      });
    };

    seriesEls.forEach(function(seriesEl) {
      seriesEl.seriesReady ? seriesElReadyHandler(seriesEl) : seriesEl.addEventListener("series-ready", seriesElReadyHandler);
    });


  },

  addYAxis: function(axisConfig, defaultColor, noRedraw) {
    if (!axisConfig) {
      this.defaultYAxisConfig = this.defaultYAxisConfig || document.createElement("px-chart-yaxis");
      this.defaultYAxisConfig.offset = this.defaultYAxisConfig.offset + 10;
      axisConfig = this.defaultYAxisConfig.buildConfig(defaultColor || "rgb(0,0,0)");
    }
    this.chart.addAxis(axisConfig, /*isX*/false, !noRedraw);
  },

  /**
   * Adds a series to the chart, adding a yAxis as needed
   *
   * @param {Object} seriesConfig
   * * {String} id
   * * {Array} data
   * * {Number} yAxis Optional. The axis index to which the series should be bound. Defaults to 0.
   * * {Number} lineWidth Optional.
   * * {Object} marker. Optional. Highcharts marker config
   * * {Object} tooltip. Optional. Highcharts tooltip config
   * @param {Boolean} noRedraw Optional. If true, does not force a chart redraw() after adding or updating the series
   */
  addSeries: function(seriesConfig, noRedraw) {
    if (seriesConfig && this.hasSeries(seriesConfig.id)) {
      this.updateAxisThreshold(seriesConfig, seriesConfig.upperThreshold, "upperThreshold");
      this.updateAxisThreshold(seriesConfig, seriesConfig.lowerThreshold, "lowerThreshold");
      this.updateSeriesEvents(seriesConfig, seriesConfig.dataEvents, /*noRedraw*/true);
      this.updateSeries(seriesConfig.id, seriesConfig.data, noRedraw);
    }
    else {
      if (!seriesConfig) {
        this.defaultSeriesConfig = this.defaultSeriesConfig || document.createElement("px-chart-series");
        seriesConfig = this.defaultSeriesConfig.buildConfig();
      }
      if (!seriesConfig.id) {
        seriesConfig.id = this.chart.series.length;
      }
      if (seriesConfig.axisId) {//associate with yAxis
        for (var i = 0; i < this.chart.yAxis.length; i++) {
          if (this.chart.yAxis[i].userOptions.id === seriesConfig.axisId) {
            seriesConfig.yAxis = i;
            break;
          }
        }
        if (typeof seriesConfig.yAxis === "undefined") {
          throw new Error("Tried to associate series " + seriesConfig.id + " to yAxis id " + seriesConfig.axisId + " but it doesn't exist.");
        }
      }
      else if (typeof seriesConfig.yAxis === "undefined") {
        seriesConfig.yAxis = 0;//apply to default yAxis...
      }
      this.updateAxisThreshold(seriesConfig, seriesConfig.upperThreshold, "upperThreshold");
      this.updateAxisThreshold(seriesConfig, seriesConfig.lowerThreshold, "lowerThreshold");
      this.updateSeriesEvents(seriesConfig, seriesConfig.dataEvents, /*noRedraw*/true);
      this.chart.addSeries(seriesConfig, !noRedraw);
      if (!noRedraw) {
        this.chart.redraw();
      }
    }
    if(this.pointMarkersToggled){
      this.togglePointMarkers([seriesConfig.id]);
    }
  },

  /**
   * Threshold lines are optionally bound to series. This function processes threshold values on a given series and
   * applies them on the y-axis that is associated with the given series.
   *
   * @param seriesConfig
   * @param thresholdValue
   * @param id
   */
  updateAxisThreshold: function(seriesConfig, thresholdValue, id) {
    var yAxisIndex = seriesConfig.yAxis || 0;
    var yAxis = this.chart.yAxis[yAxisIndex];
    yAxis.removePlotLine(id);
    if (typeof thresholdValue !== "undefined") {
      var seriesColor = seriesConfig.color;
      if (!seriesColor) {
        if (this.hasSeries(seriesConfig.id)) {
          seriesColor = this.chart.get(seriesConfig.id).options.color;
        }
        else {
          seriesColor = this.chart.options.colors[this.chart.series.length];
        }
      }
      var thresholdConfig = {
        dashStyle: "ShortDash",
        color: seriesColor,
        value: thresholdValue,
        id: id,
        width: 1,
        label: {
          align: yAxis.options.opposite ? "right" : "left",
          style: {
            fontSize: '0.8rem',
            color: seriesColor
          },
          text: thresholdValue
        }
      };
      yAxis.addPlotLine(thresholdConfig);
    }
  },

  /**
   * Updates a series on the chart, adding a default series as needed.
   *
   * @param {String} seriesId
   * @param {Array} data
   * @param {Boolean} noRedraw Optional. If true, does not force a chart redraw() after adding or updating the series
   */
  updateSeries: function(seriesId, data, noRedraw) {
    if (!this.hasSeries(seriesId)) {
      this.addSeries(/*seriesConfig*/null, /*noRedraw*/true);
    }
    this.chart.get(seriesId).setData(data, !noRedraw);
    if (!noRedraw) {
      this.chart.redraw();
    }
  },

  /**
   * Updates series events on the chart
   *
   * @param {Object} seriesConfig
   * @param {Array} events
   * @param {Boolean} noRedraw Optional. If true, does not force a chart redraw() after adding or updating the events
   *
   * @private
   */
  updateSeriesEvents: function(seriesConfig, events, noRedraw) {
    if (events) {
      var _this = this;
      events.forEach(function(event) {
        var eventConfig = {
          color: _this.seriesEventsColor,
          value: event.time,
          id: event.id,
          width: _this.seriesEventsWidth,
          textAlign: "left",
          label: {
            align: "top",
            useHTML: true,
            rotation: 0,
            style: {
              fontSize: '0.8rem',
              color: _this.dataVisColors["dv-basic-red"]
            },
            text: "<span class='style-scope px-chart data-event-icon' title='" + event.label + "' style='cursor:pointer; display:block; margin-top: -1.10rem; margin-left:-0.87rem'><i class='fa fa-lg fa-exclamation-triangle style-scope px-chart'></i> </span>"
          }
        };
        _this.chart.xAxis[0].addPlotLine(eventConfig);
      });
    }
    if (!noRedraw) {
      this.chart.redraw();
    }
  },

  /**
   * Removes a series from the chart
   *
   * @param {String} seriesId
   */
  removeSeries: function(seriesId) {
    this.chart.get(seriesId).remove();
    this.resetNavSeries();
  },

  /**
   * @private
   */
  resetNavSeries: function() {
    var nav = this.chart.get('nav');
    var series = null;
    nav.setData([]);
    if (this.chart.series.length === 0) {
      // no series
    } else if (this.chart.series[0].name === "Navigator") {
      series = this.chart.series[1];
    } else {
      series = this.chart.series[0];
    }
    if (series) {
      nav.setData(series.options.data, true);
    }
  },

  /**
   * Returns true if the chart has a series with the given id
   *
   * @param {String} seriesId
   * @return {Boolean}
   */
  hasSeries: function(seriesId) {
    return (this.chart.get(seriesId) != null);
  },

  /**
   * Toggles display of points on the chart
   *
   * @param {Array} seriesIds Optional. seriesIds ids of the series to update, or null for all
   */
  togglePointMarkers: function(seriesIds) {
    var _this = this;
    var seriesToUpdate = seriesIds ? seriesIds.map(function(id) {
      return _this.chart.get(id)
    }) : this.chart.series;
    seriesToUpdate.forEach(function(series) {
      var existingMarkerOpts = series.options.marker;
      series.update({marker: {enabled: (!existingMarkerOpts || !existingMarkerOpts.enabled)}}, /*redraw*/false);
    });
    this.chart.redraw();
    /*a global toggle calls this function with seriesId == null but this function can also be called
     to initialize a newly added series in the toggled state*/
    if(seriesIds == null) {
      this.pointMarkersToggled = !this.pointMarkersToggled;
    }
  },

  /**
   * Returns true of rangeStart / end has changed
   *
   * @param {Number} start Range start time in milliseconds since the epoch
   * @param {Number} end Range end time in milliseconds since the epoch
   * @return {Boolean}
   *
   * @private
   */
  hasExtremeChanged: function(start, end) {
    if (this.chart && this.chart.xAxis && this.chart.xAxis.length > 0) {
      var extremes = this.chart.xAxis[0].getExtremes();
      return extremes.min !== start || extremes.max !== end;
    }
    return false;
  },

  /**
   * Fires one "refresh-series" event for each series on the chart, each event has the id of the series.
   */
  refreshAllSeries: function() {
    var _this = this;
    this.chart.series.forEach(function(series) {
      _this.fire("refresh-series", series.options.id);
    });
  },


  /**
   * Sets chart extremes to given start and end times
   *
   * @private
   */
  setExtremesIfChanged: function(x, y) {
    var startTime = parseInt(x);
    var endTime = parseInt(y);
    if (this.hasExtremeChanged(startTime, endTime)) {
      this.rangeMs = {
        start: startTime,
        end: endTime
      };
      this.chart.xAxis[0].setExtremes(this.rangeMs.start, this.rangeMs.end);
    }
  },

  /**
   * @private
   * @param value
   */
  setZoom: function(value) {
    this.set('chartZoomed', value);
  },

  /**
   * @private
   */
  setZoomFalse: function() {
    this.setZoom(false);
  },

  /**
   * @private
   */
  chartZoomedObserver: function() {
    var topMargin = this.margin ? this.margin[0] : 0;
    this.$.resetZoom.style.top = (topMargin + 10) + 'px';
    this.$.resetZoom.style.display = this.chartZoomed ? 'block' : 'none';
    if (this.chart && this.chartZoomed === false) {
      this.chart.zoomOut();
    }
  },

  /**
   * Builds up highcharts config object
   * @private
   */
  buildConfig: function() {
    var self = this;

    var createSeriesColorsArray = function(colors, keysInOrder) {
      return keysInOrder.map(function(key) {
        var color = colors[key];
        if (color) {
          return color;
        }
      });
    };

    /**
     * @private
     */
    var defaultNavSeries = {
      type: 'line',
      marker: {
        enabled: false
      },
      id: 'nav',
      color: 'transparent',
      lineColor: this.dataVisColors["dv-dark-blue"],
      lineWidth: 1
    };

    /**
     * @private
     */
    var scatterNavSeries = {
      type: this.type,
      marker: {
        enabled: true
      },
      id: 'nav',
      lineColor: this.dataVisColors["dv-dark-blue"],
      lineWidth: 0
    };

    var barNavSeries = {
      type: 'column',
      marker: {
        enabled: true
      },
      id: 'nav',
      lineColor: this.dataVisColors["dv-dark-blue"],
      lineWidth: 0
    };

    var getNavSeries = function(tsChartType) {
      switch (tsChartType) {
        case 'scatter':
          return scatterNavSeries;
        case 'histogram':
        case 'bar':
          return barNavSeries;
        default:
          return defaultNavSeries;
      }
    };

    var getHighchartsChartType = function(tsChartType) {
      switch (tsChartType) {
        case 'histogram':
        case 'bar':
          return 'column';
        default:
          return tsChartType;
      }
    };

    var getXaxisLabelsOptions = function(tsChartType) {
      switch (tsChartType) {
        case 'histogram':
          return {
            align: "left",
            style: {
              fontSize: '0.8rem',
              color: "rgb(0,0,0)"
            },
            x: 3,
            y: 12,
            formatter: function() {
              return this.value;
            }
          };
        default:
          return {
            align: "left",
            style: {
              fontSize: '0.8rem',
              color: "rgb(0,0,0)"
            },
            x: 3,
            y: 12
          };
      }
    };


    var getTooltipOptions = function(tooltipType) {
      switch (tooltipType) {
        case 'condensed':
          return {
            shared: true,
            useHTML: true,
            backgroundColor: 'none',
            borderWidth: 0,
            shadow: false,
            padding: 0,
            formatter: function() {
              var s = '<div class="flex flex--right px-chart-tooltip style-scope px-chart">';
              if(this.points) {
                for (var i = 0; i < this.points.length; i++) {
                  s += '<span class="flex flex--middle u-mr-"><div style="background-color: ' + this.points[i].series.color + '" class="series-icon"></div><b class="um-b- u-p0">' + Math.round(this.points[i].y * 100) / 100 + '</b></span>';
                }
              } else {
                s += '<span class="flex flex--middle u-mr-"> <div style="background-color: ' + this.point.series.color + '" class="series-icon"></div><b class="um-b- u-p0">' + Math.round(this.point.y * 100) / 100 + '</b></span>';
              }
              s += '</div>';
              return s;
            },
            positioner: function(labelWidth, labelHeight, point) {
              var tooltipX = this.chart.chartWidth - (labelWidth + 10);
              var tooltipY = this.chart.plotTop - 40;
              return {
                x: tooltipX,
                y: tooltipY
              };
            }
          };
        default:
          return {
            shared: true,
            useHTML: true,
            backgroundColor: 'none',
            borderWidth: 0,
            shadow: false,
            padding: 0,
            formatter: function() {
              var s = '<div class="flex flex--right px-chart-tooltip style-scope px-chart">';
              if(this.points) {
                for (var i = 0; i < this.points.length; i++) {
                  s += '<span class="u-mr-"><b class="um-b- u-p0">' + Math.round(this.points[i].y * 100) / 100 + '</b><br/><b style="color: ' + this.points[i].series.color + '" class="name">' + this.points[i].series.name + '</b></span>';
                }
              } else {
                s += '<span class="u-mr-"><b class="um-b- u-p0">' + Math.round(this.point.y * 100) / 100 + '</b><br/><b style="color: ' + this.point.series.color + '" class="name">' + this.point.series.name + '</b></span>';
              }
              s += '</div>';
              return s;
            },
            positioner: function(labelWidth, labelHeight, point) {
              var tooltipX = this.chart.chartWidth - (labelWidth + 10);
              var tooltipY = this.chart.plotTop - 60;
              return {
                x: tooltipX,
                y: tooltipY
              };
            }
          };
      }
    };

    return {

      colors: createSeriesColorsArray(this.dataVisColors, this.seriesColorOrder),
      annotationsOptions: {
        enabledButtons: false
      },
      chart: {
        type: getHighchartsChartType(this.type),
        events: this.events,
        height: this.height,
        margin: this.margin,
        spacingBottom: this.spacingBottom,
        plotBorderColor: "rgb(59,59,63)",
        plotBorderWidth: this.plotBorderWidth,
        renderTo: this.$.container,
        //spacingRight: 200,
        style: {
          fontFamily: 'inherit',
          fontSize: 'inherit'
        },
        zoomType: this.zoomType,
        resetZoomButton: this.resetZoomButton,
        selectionMarkerFill: "rgba(200,231,251,0.5)"
      },


      exporting: {
        chartOptions: {
          rangeSelector: {
            enabled: false
          }
        },
        buttons: {
          enabled: true
        },
        url: this.exportServerUrl || "javascript:alert('No export-server-url attribute configrued on this chart')"
      },

      credits: {
        enabled: false
      },
      legend: this.legend,
      navigation: {
        buttonOptions: {
          enabled: false
        }
      },
      navigator: {
        enabled: !this.navigatorDisabled,
        adaptToUpdatedData: true,
        height: 50,
        margin: 15,
        outlineColor: this.dataVisColors["dv-basic-gray"],
        maskFill: 'rgba(200,231,251,0.3)',
        series: getNavSeries(this.type),
        xAxis: {
          gridLineWidth: 0,
          lineColor: this.dataVisColors["dv-basic-blue"],
          lineWidth: 1,
          labels: {
            style: {
              fontSize: '0.8rem',
              color: "rgb(0,0,0)"
            },
            y: 15
          }
        },
        yAxis: {
          lineColor: this.dataVisColors["dv-dark-blue"],
          lineWidth: 1
        }
      },
      plotOptions: {
        line: {
          lineWidth: 1,
          states: {
            hover: {
              lineWidth: 1
            }
          }
        },
        scatter: {
          marker: {
            enabled: true
          }
        },
        column: {
          borderWidth: 0,
          pointPadding: 0,
          grouping: true,
          groupPadding: 0.2
        },
        series: {
          marker: {},
          events: this.seriesEvents
        }
      },
      rangeSelector: {
        enabled: false
      },

      scrollbar: {
        enabled: false
      },
      title: {
        text: null
      },
      // tooltip: {
      //   backgroundColor: "white",
      //   borderColor: this.dataVisColors["dv-dark-gray"],
      //   shadow: false,
      //   style: {
      //     fontFamily: 'inherit',
      //     fontSize: '0.8rem'
      //   },
      //   headerFormat: "",
      //   pointFormat: '<span><span style="color:{point.color};">\u25CF</span> {series.name} </span> <span style="font-weight: bold;">{point.y}</span><br/>'
      // },
      yAxis: {
        lineColor: "rgb(59,59,63)",
        tickColor: "rgb(59,59,63)",
        labels: {
          style: {
            color: "rgb(0,0,0)"
          }
        },
        gridLineColor : "rgb(228,228,234)"
      },
      xAxis: {
        events: {
          afterSetExtremes: function(event) {
            self.fire('after-set-extremes', event);
          }
        },
        labels: getXaxisLabelsOptions(this.type),
        lineColor: "rgb(59,59,63)",
        tickColor: "rgb(59,59,63)",
        showFirstLabel: true,
        showLastLabel: true,
        startOnTick: false,
        title: {
          text: null
        }
      },
      tooltip: getTooltipOptions(this.tooltipType)
    };
  }
});
