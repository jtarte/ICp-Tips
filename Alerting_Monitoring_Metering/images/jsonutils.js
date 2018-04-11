'use-strict';

var JSONutils = function() {};

JSONutils.prototype.getObject = function(json, name, required, response)
{
    var value = json[name];

    if (value == undefined && required)
    {
        var jsonError =
        {
            description : name + " not found in JSON payload"
        };

        response.status(400).json(jsonError);

        throw jsonError;
    }

    return value;
};

JSONutils.prototype.getBoolean = function(json, name, required, response)
{
    var value = this.getObject(json, name, required, response);

    if (value == undefined)
    {
        return value;
    }

    if (!(typeof value == "boolean"))
    {
        var jsonError =
        {
            description : name + " must be Boolean"
        };

        response.status(400).json(jsonError);

        throw jsonError;
    }

    return value;
};

JSONutils.prototype.getJSON = function(json, name, required, response)
{
    var value = this.getObject(json, name, required, response);

    if (value == undefined)
    {
        return value;
    }

    if (!(typeof value == "object"))
    {
        var jsonError =
        {
            description : name + " must be a JSON object"
        };

        response.status(400).json(jsonError);

        throw jsonError;
    }

    return value;
};

JSONutils.prototype.getString = function(json, name, required, response)
{
    var value = this.getObject(json, name, required, response);

    if (value == undefined)
    {
        return value;
    }

    var text = null;

    if (!(typeof value == "string"))
    {
        text = name + " must be string";
    }
    else if (value.trim().length == 0)
    {
        text = name + " cannot be empty";
    }

    if (text)
    {
        var jsonError =
        {
            description : text
        };

        response.status(400).json(jsonError);

        throw jsonError;
    }

    return value;
};

module.exports=new JSONutils();
