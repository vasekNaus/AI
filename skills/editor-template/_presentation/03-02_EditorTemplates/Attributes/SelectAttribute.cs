using System.ComponentModel.DataAnnotations;

namespace Demo.DynamicUI.Attributes;

public class SelectAttribute(string? listPropertyName = null) : DataTypeAttribute("Select") {

    public string? ListPropertyName { get; } = listPropertyName;

}
