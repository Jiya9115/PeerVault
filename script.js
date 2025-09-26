   let currentUser = null;
    let items = JSON.parse(localStorage.getItem("items")) || { books: [], notes: [], lab: [] };
    let soldItems = JSON.parse(localStorage.getItem("soldItems")) || [];
    let users = JSON.parse(localStorage.getItem("users")) || [];

    function showPage(page) {
      document.querySelectorAll("section").forEach(sec => sec.classList.add("hidden"));
      document.getElementById(page+"Page").classList.remove("hidden");
      renderItems();
    }

    // Sign In
    document.getElementById("signinBtn").onclick = () => showPage("signin");
    document.getElementById("signinForm").onsubmit = (e) => {
      e.preventDefault();
      let uname = document.getElementById("signinName").value;
      let pass = document.getElementById("signinPass").value;
      let found = users.find(u => u.username === uname && u.password === pass);
      if(found) {
        currentUser = uname;
        sessionStorage.setItem("user", uname);
        updateLayout(true);
        showPage("home");
      } else {
        alert("Invalid username or password!");
      }
    };

    // Sign Up
    document.getElementById("signupBtn").onclick = () => showPage("signup");
    document.getElementById("signupForm").onsubmit = (e) => {
      e.preventDefault();
      let name = document.getElementById("signupName").value;
      let email = document.getElementById("signupEmail").value;
      let pass = document.getElementById("signupPass").value;
      if(users.find(u => u.username === name)) {
        alert("Username already exists!");
        return;
      }
      users.push({ username: name, email: email, password: pass });
      localStorage.setItem("users", JSON.stringify(users));
      alert("Account created! Please sign in now.");
      showPage("signin");
    };

    // Logout
    document.getElementById("logoutBtn").onclick = () => {
      sessionStorage.clear();
      currentUser = null;
      updateLayout(false);
      showPage("home");
    };

    // Update layout
    function updateLayout(loggedIn) {
      if(loggedIn) {
        document.getElementById("welcomeUser").textContent = "Hello, " + currentUser;
        document.getElementById("welcomeUser").classList.remove("hidden");
        document.getElementById("signinBtn").classList.add("hidden");
        document.getElementById("signupBtn").classList.add("hidden");
        document.getElementById("logoutBtn").classList.remove("hidden");
        document.getElementById("sellBtn").classList.remove("hidden");
        document.getElementById("soldBtn").classList.remove("hidden");
        document.getElementById("headerBar").classList.add("signedin-layout");
      } else {
        document.getElementById("welcomeUser").classList.add("hidden");
        document.getElementById("signinBtn").classList.remove("hidden");
        document.getElementById("signupBtn").classList.remove("hidden");
        document.getElementById("logoutBtn").classList.add("hidden");
        document.getElementById("sellBtn").classList.add("hidden");
        document.getElementById("soldBtn").classList.add("hidden");
        document.getElementById("headerBar").classList.remove("signedin-layout");
      }
    }

    // Restore session
    window.onload = () => {
      let user = sessionStorage.getItem("user");
      if(user) {
        currentUser = user;
        updateLayout(true);
      } else {
        updateLayout(false);
      }
      renderItems();
    };

    // Add item
    document.getElementById("addForm").onsubmit = (e) => {
      e.preventDefault();
      if(!currentUser) {
        alert("Please sign in first!");
        return;
      }
      let cat = document.getElementById("category").value;
      let newItem = {
        title: document.getElementById("title").value,
        desc: document.getElementById("desc").value,
        price: document.getElementById("price").value,
        email: document.getElementById("email").value,
        seller: currentUser
      };
      items[cat].push(newItem);
      localStorage.setItem("items", JSON.stringify(items));
      e.target.reset();
      alert("Item added successfully!");
      showPage(cat);
    };

    // Render items
    function renderItems() {
      ["books","notes","lab"].forEach(cat => {
        let container = document.getElementById(cat+"List");
        if(container) {
          container.innerHTML = "";
          if(items[cat].length === 0) {
            let msg = document.createElement("p");
            msg.textContent = `No available ${cat} found.`;
            msg.style.color = "#aaa";
            container.appendChild(msg);
          } else {
            items[cat].forEach((item, idx) => {
              let card = document.createElement("div");
              card.className = "card";
              card.innerHTML = `
                <h3>${item.title}</h3>
                <p>${item.desc}</p>
                <p><b>Price:</b> ₹${item.price}</p>
                <p><b>Seller:</b> ${item.seller}</p>
              `;

              // Always show Contact Seller
              let btn = document.createElement("button");
              btn.className = "btn";
              btn.textContent = "Contact Seller";
              btn.onclick = () => {
                if (!currentUser) {
                  alert("Please sign in to contact the seller.");
                  showPage("signin");
                } else if (currentUser === item.seller) {
                  alert("You cannot contact yourself.");
                } else {
                  window.location.href = "mailto:" + item.email + "?subject=Interested in " + item.title;
                }
              };
              card.appendChild(btn);

              // Mark as Sold (only seller)
              if(currentUser && currentUser === item.seller) {
                let sellBtn = document.createElement("button");
                sellBtn.className = "btn";
                sellBtn.textContent = "Mark as Sold";
                sellBtn.onclick = () => {
                  soldItems.push(item);
                  items[cat].splice(idx,1);
                  localStorage.setItem("items", JSON.stringify(items));
                  localStorage.setItem("soldItems", JSON.stringify(soldItems));
                  renderItems();
                };
                card.appendChild(sellBtn);
              }

              container.appendChild(card);
            });
          }
        }
      });

      // Sold list
      let soldContainer = document.getElementById("soldList");
      if(soldContainer) {
        soldContainer.innerHTML = "";
        if(soldItems.length === 0) {
          let msg = document.createElement("p");
          msg.textContent = "No sold items yet.";
          msg.style.color = "#aaa";
          soldContainer.appendChild(msg);
        } else {
          soldItems.forEach(item => {
            let card = document.createElement("div");
            card.className = "card";
            card.innerHTML = `
              <h3>${item.title}</h3>
              <p>${item.desc}</p>
              <p><b>Price:</b> ₹${item.price}</p>
              <p><b>Seller:</b> ${item.seller}</p>
              <p style="color:#ff7675;"><b>Status:</b> Sold</p>
            `;
            soldContainer.appendChild(card);
          });
        }
      }
    }

    // Clear login on close
    window.onbeforeunload = () => {
      sessionStorage.clear();
    };

    // Mobile navbar toggle
document.addEventListener("DOMContentLoaded", () => {
  const menuToggle = document.getElementById("menuToggle");
  const menuLinks = document.getElementById("menuLinks");

  if (menuToggle) {
    menuToggle.addEventListener("click", () => {
      menuLinks.classList.toggle("show");
    });
  }
});
