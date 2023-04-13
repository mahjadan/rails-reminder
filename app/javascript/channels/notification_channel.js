import consumer from "./consumer"

let notifcation_div = document.getElementById('user-notifications')
const user_id = notifcation_div.getAttribute('data-user-id')
consumer.subscriptions.create({ channel: "NotificationChannel", user_id: user_id }, {
  connected() {
    // Called when the subscription is ready for use on the server
    console.log('channel connected NotificationChannel');
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    console.log('data received: ', data);
    notifcation_div.innerHTML = `<div className="raw">
    <p>usre_id: ${user_id} </p>
    <p>${data.reminder.id} </p>
    <p>${data.reminder.title} </p>
    <p>${data.reminder.description} </p>
     </div>`
  }
});
