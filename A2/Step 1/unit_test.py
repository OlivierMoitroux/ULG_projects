from main import *


def domainUnitTest():
    """
    Test the euler integratin
    :return: a plot that tests the euler integration
    """
    dom = Domain()
    pos, speed, time = dom.eulerVec(dom.acc, p_0=-0.5, s_0=0, u=4, t_i=0,
                                    t_f=dom.discretizeTime)
    plt.gca().set_color_cycle(['blue', 'orange'])
    plt.plot(time, pos, time, speed, linewidth=3)
    plt.title("Unit test of euler integration")
    plt.xlabel("t")
    plt.ylabel("Position and speed")
    plt.legend(["Position (m)", "Speed (m/s)"])
    plt.rcParams["font.size"] = 15
    plt.savefig("illustrations/euler_unit_test.eps")
    plt.show()


if __name__ == '__main__':
    domainUnitTest()