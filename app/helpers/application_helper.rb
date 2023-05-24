module ApplicationHelper
  # docs https://human-se.github.io/rails-demos-n-deets-2020/demo-bootstrap-alerts/
  def flash_class(level)
    bootstrap_alert_class = {
      "success" => "alert-success",
      "error" => "alert-danger",
      "notice" => "alert-info",
      "alert" => "alert-danger",
      "warn" => "alert-warning"
    }
    bootstrap_alert_class[level]
  end
end
